#include <iostream>
#include <cuda.h>
#include <math.h>
#include <cstdlib>

#define DIX(u)  (u[i] - u[i-1])
#define D2IX(u) (u[i-1] - 2 * u[i] + u[i+1])

__global__ void adv_diff(double *__restrict__ u_next, const double *__restrict__ u, const double alpha, const double dx, const double dt, size_t n)
{
	size_t i = threadIdx.x + blockDim.x * blockIdx.x;
	if ((i > 0) && (i < n - 1)) {
		u_next[i] = u[i] - (dt * DIX(u) / dx) + (alpha * dt * D2IX(u) / dx / dx);
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
	
	//std::cout << "Running with hypercube size: " << sz << ", iterations: " << nt << std::endl;
	
	double *d_u, *d_u_next;
	double *u = new double[sz];
	double *initial_u = new double[sz];
	cudaMalloc(&d_u, sz * sizeof(double));
	cudaMalloc(&d_u_next, sz * sizeof(double));
	
	constexpr dim3 block_size{1024};
	dim3 grid_size{static_cast<unsigned int>((sz + block_size.x - 1) / block_size.x)};
	// Create CUDA stream for adv_diff kernels
	cudaStream_t stream;
	cudaStreamCreate(&stream);

	zero_buffer<<<grid_size, block_size>>>(d_u_next, sz);
	initial_conditions<<<grid_size, block_size>>>(d_u, sz);

	cudaMemcpy(initial_u, d_u, sz*sizeof(double), cudaMemcpyDeviceToHost);
	
	const double dx = 0.01;
	const double alpha = 0.001;
	for (size_t i = 0; i < nt; i++) {
		adv_diff<<<grid_size, block_size, 0, stream>>>(d_u_next, d_u, alpha, dx, 0.5 * 0.5 * dx * dx, sz);
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

