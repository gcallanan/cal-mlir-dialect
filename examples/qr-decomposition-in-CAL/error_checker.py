"""
@brief Scripts that interprets data produced by qrd_systolic_cordic_fixedpoint.cal and
       calculated the error in it.

This script takes in a file containing the output produced from executing the
network in qrd_systolic_cordic_fixedpoint.cal. It takes the integer values
for the A,Q and R matrices and interprets them as real values. It then
multiplies Q and R together to calculate A again. From this it determines
the error between the original A and the recalculated A.
"""
import numpy as np
import pandas as pd
import argparse
import itertools
from typing import Tuple


def runErrorChecker(m: int = 3, n:int = 19, input_file_name:str="accuracy_results/capture_M4_N4_Q3p19.txt", suppress:bool=False, print_percentiles:bool=False) -> Tuple[float,float]:
   """
   Read the A,Q and R matrices from a given text file and calculate the errors from the
   input A matrix and the A matrix produced by multiplying Q and R.

   For each element in the matrix, the error is calculated with the formula:
      (a_given_ij - a_calculated_ij)

   :param m:int describe about parameter p1
   :param n:int describe about parameter p2
   :param input_file_name:str describe about parameter p3
   :param suppress:bool describe about parameter p3
   :return:(float, float, float). A tuple containing the worst error value among all the arrays,
                           the mean error value among the arrays as well as the std deviation.
   """
   # 1. Read data from file
   with open(input_file_name, 'r') as file:
      content = file.readlines()


   # The actor network can perform QR decomposition many times. We need to verify
   # that each of these produces relatively small errors
   lrow=content[-1]
   num_arrays = int(lrow[1:lrow.find(":")]) + 1
   array_dimension=int(lrow[lrow.find("row ")+4][0:lrow.find(":")])
   highest_errors = []
   mean_errors = []
   sd_errors = []

   for i in range(0,num_arrays):

      # 2. Get the A,Q and R matrices from the read data, convert them from integers
      # to floating point numpy arrays.
         
      # This function in conjunction with itertools.takewhile stops searching the array
      # when we reach the matrix past this one. This prevents unecessary searching.
      def isLast(mat,line):
         if(line.find(mat) == 0):
            #print(line)
            if(int(line[line.find("row ")+4][0:line.find(":")]) == array_dimension):
               #print("Done")
               return False
         return True
      
      # 2.1 Get A matrix
      A_matrix_string = [x for x in itertools.takewhile(lambda line: isLast(f"A{i+1}",line), content) if x[0:x.find(":")] == f"A{i}"]
      #A_matrix_string = [x for x in content if x[0:x.find(":")] == f"A{i}"]
      A_matrix_fp = [[int(x)*(2**-n) for x in line[line.rfind(":")+2:-2].split()] for line in A_matrix_string]
      A_matrix_fp_np = np.array(A_matrix_fp)

      # 2.2 Get the R matrix
      R_matrix_string = [x for x in itertools.takewhile(lambda line: isLast(f"R{i+1}",line), content) if x[0:x.find(":")] == f"R{i}"]
      R_matrix_string.sort(key=lambda x: int(x.split("row ")[1].split(":")[0]))
      #R_matrix_string = [x for x in content if x[0:x.find(":")] == f"R{i}"]
      R_matrix_fp = [[int(x)*(2**-n) for x in line[line.rfind(":")+2:-2].split()] for line in R_matrix_string]
      R_matrix_fp_np = np.array(R_matrix_fp)

      # 2.3 Get the Q matrix
      Q_matrix_string = [x for x in itertools.takewhile(lambda line: isLast(f"Q{i+1}",line), content) if x[0:x.find(":")] == f"Q{i}"]
      Q_matrix_string.sort(key=lambda x: int(x.split("row ")[1].split(":")[0]))
      #Q_matrix_string = [x for x in content if x[0:x.find(":")] == f"Q{i}"]
      Q_matrix_fp = [[int(x)*(2**-n) for x in line[line.rfind(":")+2:-2].split()] for line in Q_matrix_string]
      Q_matrix_fp_np = np.array(Q_matrix_fp)

      # 2.4 Remove the extracted elements from R to reduce the size of the next search
      # Searching from the front as the elements are mostly in order.
      for x in A_matrix_string:
         content.remove(x)
      for x in Q_matrix_string:
         content.remove(x)
      for x in R_matrix_string:
         content.remove(x)

      # 3. Multiply the Q and R matrix together to reconstruct the A matrix
      A_reconstructed = np.matmul(Q_matrix_fp_np, R_matrix_fp_np)

      # 4. Determine the error between the source A matrix and the reconstructed one
      # Determine the error between the different elements
      errors = np.abs(A_matrix_fp_np - A_reconstructed)
      highest_error= np.max(errors)
      #mean_error= np.sqrt(np.mean(np.square(errors)))
      mean_error= np.mean(errors)
      sd_error = np.std(errors)

      # 5. Print all arrays and errors. Only print the highest error value if the
      # suppress flag is set
      if(not suppress):
         print(f"R{i} matrix:")
         print(pd.DataFrame(R_matrix_fp_np))
         print()

         print(f"Q{i} matrix: ")
         print(pd.DataFrame(Q_matrix_fp_np))
         print()

         print(f"Original A{i} matrix: ")
         print(pd.DataFrame(A_matrix_fp_np))
         print()

         print(f"A{i} matrix constructed by multiplying Q{i} and R{i}: ")
         print(pd.DataFrame(A_reconstructed))
         print()

         print(f"Error between elements of original A{i} and reconstructed A{i} |a1_ij-a2_ij|")
         print(pd.DataFrame(errors))
         print()

         print("Highest error (1 is maximum):")
         print(highest_error)
         print()

         print("Mean error (1 is maximum):")
         print(mean_error)
         print()

         print("SD error:")
         print(sd_error)
         print()

      highest_errors.append(highest_error)
      mean_errors.append(mean_error)
      sd_errors.append(np.abs(errors))

   if(not suppress):
      print("Maximum error across all input arrays/Mean error/SD across all input arrays (maximum is 1):")
      print(highest_error,mean_error, sd_error)
   
   if(not print_percentiles):
      return np.max(highest_errors),np.mean(mean_errors), np.std(sd_errors)
   else:
      return np.max(highest_errors),np.percentile(sd_errors,75), np.mean(mean_errors), np.percentile(sd_errors,25), np.min(sd_errors)

# Program to be run if this script is executed.
if(__name__ == "__main__"):
   # Process command Line arguments
   parser = argparse.ArgumentParser(
                     prog='Error Checker for QRD Systolic Array program',
                     description='A program that takes the results from the actor network and calculates the error between the results and the expected'
            )
   parser.add_argument('-n', '--fixed_point_n', type=int, default=19, help="Number of fractional bits n for Qm.n fixed point numer")
   parser.add_argument('-m', '--fixed_point_m', type=int, default=3, help="Number of integer bits m (including sign bit) for Qm.n fixed point number")
   parser.add_argument('-f', '--input_file', type=str, default="accuracy_results/capture_M4_N4_i16_Q3p19.txt", help="Name of the file containing the results from the qrd_systolic_cordic_fixedpoint.cal file")
   parser.add_argument('-s', '--suppress', help='Suppress all output from script except for the final maximum error number',
                     action='store_true')  # on/off flag
   args = parser.parse_args()

   # Execute error checker
   highest_error,mean_error, sd = runErrorChecker(args.fixed_point_m, args.fixed_point_n, args.input_file, args.suppress, False)
   print(highest_error,mean_error, sd)