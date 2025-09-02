#include <iostream>
#include <cuda.h>
#include <math.h>
#include <cstdlib>

#define DIX(u)  (u[i] - u[i-1])
#define D2IX(u) (u[i-1] - 2 * u[i] + u[i+1])
#define DX 0.01

__global__ void adv_diff(double *__restrict__ u_next, const double *__restrict__ u, const double alpha, const double dt, const double dx_inv, size_t n)
{
	size_t i = threadIdx.x + blockDim.x * blockIdx.x;
	if ((i > 0) && (i < n - 1)) {
		u_next[i] = u[i] - (dt * DIX(u) * dx_inv) + (alpha * dt * D2IX(u) * dx_inv * dx_inv);
	}
}

__global__ void conv(double *__restrict__ u_next, const double *__restrict__ u, const double *__restrict__ filter, const uint filter_size , const double alpha, const double dt, const double dx_inv, size_t n)
{
	size_t i = threadIdx.x + blockDim.x * blockIdx.x;
	if (i < n) {
		double sum = 0.0;
		for (int k = 0; k < filter_size; ++k) {
			int idx = i + k - filter_size / 2;
			if (idx >= 0 && idx < n) {
				sum += u[idx] * filter[k];
			}
		}
		u_next[i] = sum;
	}
}

__global__ void zero_buffer(double *__restrict__ u, size_t n)
{
	size_t i = threadIdx.x + blockDim.x * blockIdx.x;
	if (i < n) {
		u[i] = 0.0;
	}
}

__global__ void initial_conditions(double *__restrict__ u, size_t n)
{
	size_t i = threadIdx.x + blockDim.x * blockIdx.x;
	if (i < n) {
		const double x = i / (static_cast<double>(n) - 1);
		u[i] = exp(-(x-0.5)*(x-0.5)/0.01);
	}
}

void print_gpu_info()
{
	int dev_count;
	cudaDeviceProp props;
	cudaGetDeviceCount(&dev_count);
	std::cout << "[CUDA] Found " << dev_count << " GPUs. " << std::endl;
	for (int i = 0; i < dev_count; i++) {
		cudaGetDeviceProperties(&props, i);
		std::cout << "[CUDA] GPU #" << i << " Name: " << props.name << "\n"
			  << "\t Compute Capability: " << props.major << "." << props.minor << "\n"
			  << "\t Memory: " << (props.totalGlobalMem >> 30) << " GB\n"
			  << "\t Shared Memory/MP: " << (props.sharedMemPerMultiprocessor >> 10) << " KB\n"
			  << "\t L2 Cache Size: " << (props.l2CacheSize >> 20) << " MB\n"
			  << "\t #MPs: " << props.multiProcessorCount << "\n"
			  << "\t Warp Size: " << props.warpSize << " threads\n";
	}
}

int main(int argc, char* argv[])
{
	size_t sz = 1000000; // Default hypercube size
	size_t nt = 1000;    // Default number of iterations
	
	// Parse command line arguments
	if (argc >= 2) {
		sz = std::atoi(argv[1]);
		if (sz <= 0) {
			std::cerr << "Error: hypercube size must be positive" << std::endl;
			return 1;
		}
	}
	if (argc >= 3) {
		nt = std::atoi(argv[2]);
		if (nt <= 0) {
			std::cerr << "Error: number of iterations must be positive" << std::endl;
			return 1;
		}
	}
	// Parse optional third argument for conv_kernel flag
	bool conv_kernel = false;
	if (argc >= 4 && std::atoi(argv[3]) != 0) {
		conv_kernel = true;
	}
	
	//std::cout << "Running with hypercube size: " << sz << ", iterations: " << nt << std::endl;
	
	uint filter_length = 3;
	double *d_u, *d_u_next;
	double *u = new double[sz];
	double *initial_u = new double[sz];
	cudaMalloc(&d_u, sz * sizeof(double));
	cudaMalloc(&d_u_next, sz * sizeof(double));

	// Create and initialize filter array on host
	double filter[3] = {0.00275, 0.997, 0.00025};
	double *filter_device;
	cudaMalloc(&filter_device, 3 * sizeof(double));
	cudaMemcpy(filter_device, filter, 3 * sizeof(double), cudaMemcpyHostToDevice);
	
	constexpr dim3 block_size{1024};
	dim3 grid_size{static_cast<unsigned int>((sz + block_size.x - 1) / block_size.x)};
	// Create CUDA stream for adv_diff kernels
	cudaStream_t stream;
	cudaStreamCreate(&stream);

	zero_buffer<<<grid_size, block_size>>>(d_u_next, sz);
	initial_conditions<<<grid_size, block_size>>>(d_u, sz);

	cudaMemcpy(initial_u, d_u, sz*sizeof(double), cudaMemcpyDeviceToHost);
	
	const double alpha = 0.001;
	const double dx_inv = 1.0 / DX;
	for (size_t i = 0; i < nt; i++) {
		if (conv_kernel) {
			conv<<<grid_size, block_size, 0, stream>>>(d_u_next, d_u, filter_device, filter_length, alpha, 0.5 * 0.5 * DX * DX, dx_inv, sz);
		} else {
			adv_diff<<<grid_size, block_size, 0, stream>>>(d_u_next, d_u, alpha, 0.5 * 0.5 * DX * DX, dx_inv, sz);
		}
		std::swap(d_u, d_u_next);
	}
	
	// Synchronize the stream at the end of the loop
	cudaStreamSynchronize(stream);
	
	// Check whether nt is even or odd: where the result is depends on that due to swapping the pointers every loop iteration
	double *res = (nt & 0x1) ? d_u_next : d_u;
	cudaMemcpy(u, res, sz*sizeof(double), cudaMemcpyDeviceToHost);

	// Print initial_u in a line separated by a space, with precision 12

	std::cout.precision(12);
	for (size_t i = 0; i < sz; ++i) {
		std::cout << initial_u[i];
		if (i != sz - 1) std::cout << " ";
	}
	std::cout << std::endl;
	// Print u in a line separated by a space, with precision 12
	std::cout.precision(12);
	for (size_t i = 0; i < sz; ++i) {
		std::cout << u[i];
		if (i != sz - 1) std::cout << " ";
	}
	std::cout << std::endl;

	cudaFree(d_u);
	cudaFree(d_u_next);

	delete[] initial_u;
	delete[] u;

	return 0;
}

