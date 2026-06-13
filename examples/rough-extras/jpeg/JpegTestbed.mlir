module {
  memref.global "private" constant @__cmr_0 : memref<3xi8> = dense<[0, 1, 1]>
  memref.global "private" constant @__cmr_1 : memref<3xi8> = dense<[2, 3, 3]>
  memref.global "private" constant @__cmr_2 : memref<3xi32> = dense<[4, 1, 1]>
  memref.global "private" constant @__cmr_3 : memref<3867xi8> = dense<[106, -40, -1, -32, 0, 16, 74, 70, 73, 70, 0, 1, 1, 1, 0, 72, 0, 72, 0, 0, -1, -37, 0, 67, 0, 16, 11, 12, 14, 12, 10, 16, 14, 13, 14, 18, 17, 16, 19, 24, 40, 26, 24, 22, 22, 24, 49, 35, 37, 29, 40, 58, 51, 61, 60, 57, 51, 56, 55, 64, 72, 92, 78, 64, 68, 87, 69, 55, 56, 80, 109, 81, 87, 95, 98, 103, 104, 103, 62, 77, 113, 121, 112, 100, 120, 92, 101, 103, 99, -1, -37, 0, 67, 1, 17, 18, 18, 24, 21, 24, 47, 26, 26, 47, 99, 66, 56, 66, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, -1, -64, 0, 17, 8, 0, -112, 0, -80, 3, 1, 34, 0, 2, 17, 1, 3, 17, 1, -1, -60, 0, 31, 0, 0, 1, 5, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1, -60, 0, 31, 1, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, -1, -60, 0, -75, 16, 0, 2, 1, 3, 3, 2, 4, 3, 5, 5, 4, 4, 0, 0, 1, 125, 1, 2, 3, 0, 4, 17, 5, 18, 33, 49, 65, 6, 19, 81, 97, 7, 34, 113, 20, 50, -127, -111, -95, 8, 35, 66, -79, -63, 21, 82, -47, -16, 36, 51, 98, 114, -126, 9, 10, 22, 23, 24, 25, 26, 37, 38, 39, 40, 41, 42, 52, 53, 54, 55, 56, 57, 58, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 90, 99, 100, 101, 102, 103, 104, 105, 106, 115, 116, 117, 118, 119, 120, 121, 122, -125, -124, -123, -122, -121, -120, -119, -118, -110, -109, -108, -107, -106, -105, -104, -103, -102, -94, -93, -92, -91, -90, -89, -88, -87, -86, -78, -77, -76, -75, -74, -73, -72, -71, -70, -62, -61, -60, -59, -58, -57, -56, -55, -54, -46, -45, -44, -43, -42, -41, -40, -39, -38, -31, -30, -29, -28, -27, -26, -25, -24, -23, -22, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -1, -60, 0, -75, 17, 0, 2, 1, 2, 4, 4, 3, 4, 7, 5, 4, 4, 0, 1, 2, 119, 0, 1, 2, 3, 17, 4, 5, 33, 49, 6, 18, 65, 81, 7, 97, 113, 19, 34, 50, -127, 8, 20, 66, -111, -95, -79, -63, 9, 35, 51, 82, -16, 21, 98, 114, -47, 10, 22, 36, 52, -31, 37, -15, 23, 24, 25, 26, 38, 39, 40, 41, 42, 53, 54, 55, 56, 57, 58, 67, 68, 69, 70, 71, 72, 73, 74, 83, 84, 85, 86, 87, 88, 89, 90, 99, 100, 101, 102, 103, 104, 105, 106, 115, 116, 117, 118, 119, 120, 121, 122, -126, -125, -124, -123, -122, -121, -120, -119, -118, -110, -109, -108, -107, -106, -105, -104, -103, -102, -94, -93, -92, -91, -90, -89, -88, -87, -86, -78, -77, -76, -75, -74, -73, -72, -71, -70, -62, -61, -60, -59, -58, -57, -56, -55, -54, -46, -45, -44, -43, -42, -41, -40, -39, -38, -30, -29, -28, -27, -26, -25, -24, -23, -22, -14, -13, -12, -11, -10, -9, -8, -7, -6, -1, -38, 0, 12, 3, 1, 0, 2, 17, 3, 17, 0, 63, 0, -37, -47, 100, -102, 109, 30, -41, -54, -106, 72, -41, -56, 80, 62, -96, 99, -113, 106, -66, -55, 112, 115, -117, -71, 6, 71, 3, 29, 13, 102, 104, -105, -112, 91, 104, 54, 98, 71, -63, -14, -57, 0, 102, -89, 75, -7, -90, -111, -124, 48, -27, 49, -14, -79, -2, -76, -100, -38, 51, -10, 49, 122, -105, -65, 124, 50, 77, -53, 99, 112, 56, 61, 7, -88, -88, -98, -16, 22, -37, 2, 25, 91, -44, 116, 31, -115, 68, 32, 121, 27, 55, 46, 95, -48, 14, 20, 85, -120, -44, 14, -128, 1, -24, 42, 92, -101, 52, -116, 20, 118, 34, 48, 60, -92, 27, -121, 44, 63, -72, -68, 47, -1, 0, 94, -90, 85, -38, -72, 0, 12, 122, 116, 20, -110, 48, 81, -110, 64, 3, -87, 53, 78, 125, 74, 24, -57, -55, -13, -97, 92, -32, 84, -108, 94, 28, 85, 121, -11, 8, 97, -56, -35, -67, -121, 101, -1, 0, 26, -50, -51, -11, -15, -7, 84, -120, -3, 91, -27, 95, -2, -67, 89, -121, 73, -119, 112, -45, -79, -108, -6, 99, 10, 63, 10, 122, -127, 92, -34, -35, 94, 18, -74, -24, 112, 123, 39, -11, 53, 44, 58, 81, 111, -102, -26, 67, -21, -78, 63, -15, -83, 72, -30, 0, 5, 85, 1, 69, 78, -86, 23, -21, 77, 33, 92, -81, 111, 108, -112, -57, -74, 24, -62, 45, 61, -95, 39, -111, -116, -3, 106, 122, 42, -84, 5, 25, -31, 45, 19, 35, -88, 33, -122, 48, 121, 21, -117, 44, 83, -23, -45, -119, 98, 57, -116, -15, -109, -45, -24, 127, -58, -70, -113, 106, -91, 117, 110, 10, -73, 25, 82, 48, 69, 75, 65, 114, 43, 91, -108, -71, -117, 114, -98, 71, 81, -36, 83, -40, 2, 72, 62, -107, -117, 60, 50, -23, -45, -119, -95, 57, -116, -12, -49, 111, 99, -2, 53, -85, 105, 116, -105, 81, 22, 83, -122, 31, 121, 79, 81, 82, 50, -74, -26, -79, -109, 119, 88, 24, -4, -54, 58, -95, -11, 30, -43, 127, 43, 34, -122, 82, 8, 35, 32, -114, -11, 28, -85, -107, -63, 25, -86, 113, 72, -42, 45, -122, -55, -127, -113, 79, -18, 31, -16, -96, 7, 75, 27, 90, 72, 103, -123, 73, 67, -52, -120, 63, -104, -85, 36, 71, 113, 15, 56, 100, 117, -19, -34, -92, -31, -64, 32, -126, 8, -49, 21, 73, -9, 88, -71, 97, -51, -69, 30, 71, -9, 15, -81, -46, -128, 22, 23, 49, 74, 45, -89, 57, 35, -104, -36, -1, 0, 16, -12, -6, -44, 83, 43, 90, 92, 60, -15, -126, -56, -33, -21, 23, -6, -118, -73, 36, 73, 119, 110, 6, 113, -97, -103, 88, 117, 7, -44, 84, 41, 43, 50, 52, 83, -116, 76, -125, -97, 70, 30, -94, -127, -111, 104, 113, -93, 104, 54, -120, 81, 72, 104, -58, -32, 71, 90, -45, 85, 8, -127, 84, 0, -93, -128, 7, 65, 89, 58, 29, -52, 49, -24, -106, -91, -33, 27, 99, 3, 29, -51, 58, 93, 82, 73, 91, -53, -76, -119, -117, 123, 12, -97, -2, -75, 54, 35, 74, 105, 22, 53, -53, -80, 81, -22, 106, -123, -58, -84, -111, -115, -80, -82, 73, -24, 79, -8, 83, 34, -45, 110, 103, 96, -9, 82, -20, -10, 7, 115, 127, -128, -83, 27, 123, 27, 123, 127, -11, 113, -115, -35, -40, -14, 79, -29, 74, -64, 101, -83, -75, -11, -13, 110, -104, -7, 73, -22, -3, 127, 5, -83, 11, 125, 58, -34, 3, -72, -87, -111, -1, 0, -68, -4, -1, 0, -6, -86, -35, 25, -90, 1, -34, -100, -85, -109, -3, 106, 55, 117, -116, 101, -40, 40, -9, 53, 58, 112, 41, -95, 15, 0, 1, -127, 75, 73, 69, 88, -123, -94, -118, 40, 0, -92, 35, 52, -76, -122, -128, 41, -49, 16, -27, 72, 5, 91, -79, -84, 75, -101, 105, 108, 37, -5, 69, -71, 62, 95, 127, -10, 125, -113, -88, -82, -114, 85, -36, -92, 85, 70, 0, -27, 72, -56, 60, 17, 80, -48, -47, 94, -46, -18, 59, -72, -78, 56, 97, -9, -105, -46, -100, -23, -71, 89, 112, 9, -57, 25, -84, -21, -53, 55, -76, 113, 115, 104, 72, 81, -44, 127, 119, -1, 0, -83, 87, 108, -18, -110, -18, 60, 112, -82, 7, 35, 63, -83, 72, -58, 70, -26, -59, -43, 31, 62, 67, 116, 63, -36, 63, -31, 87, -39, 67, -114, -128, -126, 57, -9, -88, 46, 35, 15, 24, 4, 100, 99, 21, 5, -68, -90, -43, -60, 82, 19, -28, -97, -70, -57, -8, 125, -113, -75, 0, 58, 48, 108, -36, 33, 63, -72, 99, -14, -109, -4, 7, -48, -5, 84, -73, 112, -7, -79, -121, 83, -74, 68, -5, -83, -3, 62, -107, 97, -47, 100, 66, -92, 2, 8, -63, 21, 73, 25, -83, -49, -109, 33, 37, 72, 62, 91, -97, -28, 125, -24, 2, -114, -119, -89, 37, -58, -105, 105, 44, -50, -60, 121, 64, 4, 94, 7, -29, 91, -79, 69, 28, 41, -78, 52, 84, 95, 64, 49, 89, -2, 30, -1, 0, -112, 21, -97, -3, 115, 21, 122, 89, -29, -120, 124, -18, 7, -73, 122, -89, -96, -119, 58, 10, 51, -114, 115, 89, -77, 106, -120, -92, -7, 107, -57, -9, -101, -4, 42, -109, -36, -36, 94, 54, 35, 87, -112, 123, 12, 45, 43, -116, -43, -106, -2, 8, -14, 3, 111, 35, -78, -1, 0, -115, 103, -36, 106, -17, -126, -79, -112, -97, -18, -14, 127, 58, 116, 26, 84, -78, 0, -41, 50, 109, 7, -8, 18, -81, -63, 99, 111, 111, -52, 113, -128, 127, -68, 121, 52, 88, 70, 125, -124, 83, -36, 92, -84, -78, -93, 8, -57, 59, -97, -110, 107, 121, 106, 33, -55, 21, 40, 32, 12, -109, -127, 86, -74, 1, -12, 84, 15, 119, 18, 119, 45, -12, -86, -78, -21, 16, -57, -44, 126, -76, -100, -110, 11, 51, 74, -118, -59, 111, 16, -62, -67, 16, -102, -120, -8, -102, 44, -32, 66, 127, -17, -86, 92, -24, 124, -84, -33, -92, -84, 7, -15, 50, 46, 63, 113, -1, 0, -113, 82, -89, -119, 17, -1, 0, -27, -112, 31, -115, 28, -24, 57, 89, -72, 69, 84, -107, 113, 39, 79, 122, -86, -102, -46, -71, -58, -43, -49, -42, -92, 107, -63, 33, 4, -58, 71, -48, -46, 114, 77, 7, 43, 67, -114, 112, 112, 1, -6, -42, 101, -27, -109, -37, -65, -38, 108, -14, -96, 114, 84, 118, -6, 123, 86, -102, -56, -113, -64, -56, 62, -122, -100, -68, 82, 2, -91, -99, -14, 93, -96, 82, 0, -112, 117, 25, -3, 69, 76, -47, 7, 87, 7, 4, 17, -118, -95, -88, 89, 52, 111, -10, -101, 80, 67, 14, 74, -88, -3, 71, -8, 84, -6, 109, -22, -36, -95, 12, 64, -108, 117, 30, -93, -38, -128, 11, 91, -109, 3, 8, 103, 63, 33, -31, 28, -10, -10, 53, 110, 120, -106, 72, -103, 93, 114, 8, -88, 100, -123, 101, -56, 117, -56, 35, 20, -56, -91, 107, 114, 109, -26, 63, 41, 4, 70, -28, -2, -122, -128, 50, 52, -53, -55, -1, 0, -77, 45, -95, -121, 115, 98, 48, 48, -94, -81, 67, -89, 93, 77, -52, -82, 34, 7, -73, 83, 86, 60, 58, 0, -48, -20, -56, -64, -52, 99, 56, -17, 90, 85, 86, 17, 78, 13, 46, -38, 44, 22, 79, 49, -67, 95, -4, 42, -30, -88, 85, 1, 64, 3, -48, 12, 82, -26, -109, 52, 0, -67, 41, 56, -94, -104, -20, 6, 1, 35, 38, -128, 9, 103, -114, 4, 46, -28, 96, 119, -19, 89, 23, 26, -85, 75, -2, -84, 97, 125, 79, -8, 84, 26, -92, -58, 89, 112, 73, -38, -89, -127, 89, -51, 40, 99, -80, 117, -19, 89, 73, -74, -20, 90, 72, -79, 53, -28, -114, 113, -72, -97, -27, 85, -99, 76, -100, -69, -111, -12, -96, -85, 99, 11, -41, -42, -93, 107, 114, -36, -68, -121, -16, -90, -94, 85, -59, -14, -94, 63, -60, 91, -15, -96, -63, 30, 56, 20, -43, -121, 111, 67, 82, 1, -127, 78, -61, 76, -119, -19, -43, -123, 39, -110, -127, 112, 27, 7, -41, 53, 51, 31, -106, -85, 73, 19, 49, -54, -100, 26, 44, 49, -15, -55, 36, 109, -122, 57, 29, -115, 106, 89, 93, 56, -107, 87, -8, 79, 106, -54, 68, -108, 12, 62, 24, 122, -118, -38, -45, 108, -38, 68, 87, 43, -127, -37, 53, 54, -77, 37, -78, -20, -105, 81, -37, -108, 47, -98, 79, 110, -34, -11, 117, 29, 93, 67, 41, 4, 30, -124, 85, 123, -117, 40, -18, 99, -37, -9, 100, 94, 3, -29, -91, 102, -57, 44, -6, 108, -34, 84, -118, 76, 103, -100, 127, 81, 87, 99, 51, 112, 26, -53, -66, -80, 43, 39, -38, 109, 1, 86, 31, 51, 42, -6, -6, -113, -16, -85, -47, 76, -110, -94, -68, 109, -71, 91, -72, -87, 115, -59, 48, 40, 88, -34, 11, -109, -79, -122, 31, 28, -6, 31, -91, 88, -68, -123, 100, -123, -127, 25, 24, -86, -105, -10, 39, 127, -38, 45, 65, 18, 3, -106, 85, -17, -18, 42, 107, 91, -43, -71, -116, -85, -15, 40, 7, 35, -42, -112, 11, -31, -1, 0, -7, 1, -39, -13, -1, 0, 44, -59, 104, -9, -21, 92, -26, -107, -88, -76, 58, 77, -84, 75, -80, 17, 24, -9, 63, -107, 88, -33, 123, 113, -46, 57, 72, 61, -40, -19, 21, 77, -120, -43, -106, -22, 24, -66, -4, -128, 31, 64, 114, 106, -92, -102, -84, 97, 114, -120, 79, -69, 28, 10, -53, -68, -74, -67, -73, 70, -105, 106, -78, -113, -67, -27, -13, -118, -53, -5, 66, -56, 114, -52, 73, -9, 52, -128, -39, -101, 88, -111, -78, 3, -32, 122, 32, -2, -75, 76, -33, 73, -68, 50, -126, 88, 114, 11, 28, -43, 64, -64, -45, -78, 41, 12, -67, 37, -52, 87, 40, 76, -97, -69, -109, 30, -103, 6, -77, 109, -80, -45, -73, 57, -20, 42, 78, 8, 57, -50, 61, -87, -74, -112, -104, -18, 125, 84, -116, -26, -117, 106, 82, -67, -119, -28, 111, 45, 125, -22, -77, 57, 35, 36, -102, -71, 44, 91, -86, -108, -74, -118, 88, -109, -72, -2, 52, 20, 64, 39, 34, 76, 43, 126, -75, 114, 22, 46, 48, 69, 87, -114, -56, 6, -56, 80, 42, -20, 81, 108, 20, 12, -126, -23, -116, 41, -112, 42, -100, 115, -105, 108, -106, 2, -75, -18, 33, 18, 67, -125, 89, 77, 98, 3, 125, -48, 69, 0, -53, 16, 72, -34, 96, 86, -63, -49, 66, 59, -41, 95, 111, -60, 8, 61, 20, 87, 39, 107, 110, -86, -54, 64, -58, 59, 87, 71, 101, 125, 20, -1, 0, -70, -50, -39, 87, -8, 79, 127, -91, 4, 72, -67, -36, 26, -114, 120, 35, -72, -116, -92, -85, -111, -40, -9, 31, 74, 120, -23, -45, 52, -76, -55, 48, -35, 46, 52, -71, -14, 50, -47, 49, -21, -39, -65, -64, -42, -83, -75, -60, 119, 17, -17, -116, -3, 71, 113, 83, -70, -92, -111, -107, 117, 12, -92, 114, 13, 98, -36, -38, -51, -89, 73, -10, -117, 118, 38, 46, -2, -34, -58, -128, 54, 106, -123, -3, -111, 114, 103, -73, -30, 81, -55, 3, -116, -1, 0, -11, -22, 91, 59, -60, -71, 76, -114, 24, 117, 90, -76, -33, 112, -3, 40, 2, -113, -121, 99, 69, -47, 45, 24, 34, -18, 49, -116, -100, 114, 107, 69, -37, 10, 73, 29, 42, -105, -121, -121, -4, 72, -84, -1, 0, -21, -104, -85, -110, -128, 88, 15, 74, -90, 34, -77, 19, -7, -42, 6, -81, -91, -95, 111, 58, 1, -80, -98, -72, -23, 93, 19, 47, -83, 65, 42, 7, -116, -93, 14, -75, 32, 113, 38, 73, 96, 109, -78, 12, 123, -43, -120, -18, 3, 14, -75, 126, -14, -40, 6, 42, -29, 53, -111, 53, -93, 70, 75, 68, 113, -19, 76, 11, -56, -31, -72, -51, 91, -119, -77, 49, 80, 56, 3, -109, -17, 88, -80, -50, -56, -31, 92, 16, 115, 91, 80, -32, -88, -112, 127, 23, -21, 83, 99, 72, -19, 98, -42, -48, 71, 52, -58, 65, 78, 45, -118, -115, -97, 52, 20, -122, -112, 5, 62, 37, -36, -29, 60, 10, -123, -107, -120, 61, -86, -71, 51, -93, -25, 127, 30, -122, -126, -115, -39, 82, 35, 111, -76, 40, -50, 43, 33, -66, 89, 10, -73, 20, 27, -71, 89, 118, -87, -26, -101, -27, 59, 40, 44, 114, -34, -76, 45, -124, -38, 108, -79, 24, 21, 78, 87, 116, -71, 99, -50, -48, 120, 35, -88, -6, 85, -104, -37, 4, 3, -42, -87, -54, 119, 59, 31, 122, 12, -28, 109, 88, 106, -32, -128, -105, 13, -57, 65, 39, -8, -42, -62, -80, 42, 8, 60, 123, 87, 18, -92, -87, -54, -42, -115, -122, -90, -10, -8, 94, 90, 62, -24, 79, -14, -96, -109, -89, -56, -91, -32, -126, 8, -56, 61, -115, 87, -126, -26, 43, -120, -73, -60, -39, -2, 98, -90, 86, -50, 59, 31, 74, 96, 101, 94, 105, -17, 3, -3, -94, -49, 56, 28, -108, 29, -66, -107, 45, -106, -96, -73, 8, 81, -2, 89, 49, -45, -41, -23, 90, 61, 13, 103, 106, 26, 96, -109, 51, 91, -4, -78, -114, 72, 28, 3, -1, 0, -41, -96, 9, -68, 63, -58, -125, 103, -1, 0, 92, -59, 91, -5, -39, 61, 51, 84, 116, 47, -7, 0, 89, 15, 88, -59, 95, -20, 120, -86, 98, 35, 97, -125, 76, 117, -51, 74, -61, 35, -102, 111, 21, 32, 102, -33, -63, -71, 55, -29, -111, -38, -79, -90, -120, 30, -43, -45, -56, 6, 113, -118, -58, -68, -73, -39, 41, -58, 112, 121, 20, 32, 49, -38, 21, -18, 51, -17, 74, -105, 77, 0, -14, -128, 37, 73, -32, -6, 85, -119, 19, 25, -86, 114, -60, 88, -116, 122, -10, -92, 82, 102, -60, 103, 49, -82, 122, -30, -105, 0, 115, 81, 69, 32, 32, 12, -10, -87, 25, -127, 92, 119, -95, -106, -120, 30, -30, 52, 108, 51, 1, -8, -44, 111, 50, 58, -4, -86, -57, -23, 82, 11, 8, -104, -18, 101, 4, -11, 36, -118, -112, 90, -38, 110, -2, 56, -101, 24, -54, -75, 8, -92, -118, 73, 42, 33, -50, -42, -4, 69, 76, -105, -79, 72, -5, 80, -2, 20, -25, -77, -73, -35, -13, -56, 92, 14, -36, -44, -62, -38, 25, 87, -9, 113, 42, -19, -23, -127, 64, 52, 33, 80, 50, -2, -43, -101, -112, 73, -26, -81, -50, -58, 40, -103, 79, 28, 98, -77, -79, -114, -100, 123, -48, 102, -57, 82, 16, 115, -111, -59, 48, -106, -50, 55, 26, 3, -74, 114, -40, 11, 72, 69, -85, 107, -71, 96, -112, 58, -79, 13, -21, -21, -11, -82, -118, -57, 81, -114, -28, -124, 111, -110, 79, 76, -16, 126, -107, -54, 121, -117, -17, 82, 36, -91, 113, -125, -111, -4, -87, -120, -19, 73, -91, -50, 80, -3, 43, 14, -61, 87, -32, 37, -63, -56, -24, 31, -45, -21, 91, 33, -127, 66, 65, 4, 17, -38, -128, 42, 104, 60, -24, -74, 126, -47, -118, -68, 73, -55, 29, 79, -91, 81, -48, 7, -4, 73, 44, -1, 0, -21, -104, -85, -3, 42, -40, -124, -19, 73, -51, 56, -12, -30, -109, -75, 32, 24, -62, -86, -36, -61, -26, -95, 3, 25, 29, 42, -31, -88, -120, -59, 33, -104, 18, 39, 80, -62, -85, -104, -62, -80, 35, -42, -75, -17, -96, -63, -34, 7, 7, -83, 81, 100, 20, -48, -109, -77, 51, -90, 102, -123, -60, -125, -18, -73, 63, -29, 86, 96, -104, 51, 41, -49, 21, 17, 41, -71, -95, -105, -3, 91, -12, 63, -35, 62, -75, 79, -9, -106, 114, 109, 124, 24, -40, -4, -84, 15, 20, -25, 19, -82, 80, -42, -24, -23, 84, -121, 77, -93, -91, 84, -102, -42, 92, -110, -93, 34, -96, -75, -67, 0, 14, 114, 43, 74, 59, -88, -36, 3, -70, -78, -43, 19, -89, 82, -124, 118, -109, 51, 124, -54, 64, -9, -85, -23, 16, -123, 57, -89, 53, -62, -127, -37, -13, -86, 115, -35, -17, 109, -85, -12, -93, 113, 59, 34, -115, -12, -95, -90, 35, -46, -85, -126, 13, 45, -24, 43, 112, -36, 100, 96, 115, 80, -119, 6, 58, -43, 51, 38, -103, 54, 41, -123, 115, 76, -13, 125, 41, -62, 76, -6, 82, 16, -123, 104, 71, 9, -14, -98, -12, -18, 123, -45, 72, 30, -108, 1, 32, 98, -89, 114, -43, -5, 29, 74, 75, 127, -105, -86, -98, -88, 122, 126, 30, -107, -100, -93, 98, -29, -67, 41, 35, 111, 60, 80, 7, 87, -96, -100, 104, 118, 127, -11, -52, 85, -15, -12, -84, -35, 8, -1, 0, -60, -106, -52, 127, -45, 49, 90, 25, -59, 104, -55, 29, 77, 39, -102, 1, -96, -102, 67, 16, -45, 72, -25, 20, -122, 69, 7, -109, -51, 70, -41, 3, 63, 42, -25, -36, -47, 97, 92, 89, -109, 114, 16, 70, 115, 89, 51, -62, -21, -112, 7, 35, -75, 92, 107, -105, 102, 33, 113, -97, 81, 85, -102, 93, -57, 119, 27, -127, -25, 53, 73, 9, -77, 46, -14, 18, 64, 100, 31, 55, -89, -83, 82, 37, 101, 67, 19, -16, 127, -111, -83, 123, -94, 48, 76, -101, 84, -98, 64, -51, 103, 76, -120, -36, -106, 92, -113, -30, 12, 51, 86, 105, 10, -51, 43, 51, 60, 60, -106, -50, 84, -12, 21, 102, 59, -90, 35, 32, 26, -111, -83, 124, -8, -72, -106, 34, -61, -90, 88, 3, 85, -116, 18, 91, 55, -50, 0, 31, 81, -118, -54, 74, -58, -105, 79, 98, -48, -98, 86, -32, 103, -15, -85, 118, -56, 115, -109, -51, 85, -127, -108, -13, -71, 127, 49, 87, -29, 116, 3, -17, -81, -3, -12, 42, 4, -52, -21, -41, 43, 124, -40, 56, -32, 82, 53, -71, -107, 119, -60, 62, 126, -21, -21, 81, 95, -80, 55, -59, -125, 12, 16, 59, -42, -99, -102, 34, 32, 118, 101, -49, 97, -72, 86, -54, -51, 106, 116, -62, 42, 113, -77, 50, -35, 36, -123, -74, -53, 25, 70, -9, -89, 12, -98, 3, 83, -34, -22, 66, -18, 25, -125, -58, 88, -4, -116, 71, -24, 123, 83, -106, 56, 39, 108, 91, -53, -27, -65, -4, -13, -112, -9, -10, 53, -107, -114, 38, 51, 59, 78, 15, 90, 114, 48, -49, 34, -98, -74, -109, -112, 11, 8, -64, -55, 0, -105, 21, 57, -45, -103, 66, 22, -110, 28, 30, -69, 88, 113, 82, -35, -122, -107, -54, -52, -64, -114, -125, 52, -36, 22, -29, 28, 86, -69, -23, -106, -56, -60, 37, -64, -108, 113, -113, -100, 40, -85, 113, 90, 105, -79, 66, -54, -32, 76, -28, 125, -30, -64, 96, -5, 115, 75, -102, 55, -36, 124, -82, -64, -1, -39]>
  memref.global "private" constant @__cmr_4 : memref<64xi6> = dense<[0, 1, 5, 6, 14, 15, 27, 28, 2, 4, 7, 13, 16, 26, 29, 42, 3, 8, 12, 17, 25, 30, 41, 43, 9, 11, 18, 24, 31, 40, 44, 53, 10, 19, 23, 32, 39, 45, 52, 54, 20, 22, 33, 38, 46, 51, 55, 60, 21, 34, 37, 47, 50, 56, 59, 61, 35, 36, 48, 49, 57, 58, 62, 63]>
  memref.global "private" constant @__cmr_5 : memref<64xi16> = dense<[1024, 1138, 1730, 1609, 1024, 1609, 1730, 1138, 1138, 1264, 1922, 1788, 1138, 1788, 1922, 1264, 1730, 1922, 2923, 2718, 1730, 2718, 2923, 1922, 1609, 1788, 2718, 2528, 1609, 2528, 2718, 1788, 1024, 1138, 1730, 1609, 1024, 1609, 1730, 1138, 1609, 1788, 2718, 2528, 1609, 2528, 2718, 1788, 1730, 1922, 2923, 2718, 1730, 2718, 2923, 1922, 1138, 1264, 1922, 1788, 1138, 1788, 1922, 1264]>
  // libc I/O wrapper declarations for std.io intrinsics
  func.func private @__cal_fopen(!llvm.ptr, !llvm.ptr) -> i64
  func.func private @__cal_fclose(i64) -> i32
  func.func private @__cal_fread(i64, i64, i64, i64) -> i64
  func.func private @__cal_fwrite(i64, i64, i64, i64) -> i64
  func.func private @__cal_fseek(i64, i64, i32) -> i32
  func.func private @__cal_ftell(i64) -> i64
  func.func private @__cal_feof(i64) -> i32
  func.func private @__cal_fflush(i64) -> i32
  func.func private @__cal_ferror(i64) -> i32
  func.func private @__cal_fgetc(i64) -> i32
  func.func private @__cal_fputc(i32, i64) -> i32
  func.func private @__cal_rewind(i64) -> ()
  func.func private @__cal_clearerr(i64) -> ()

  // libc string wrapper declarations for std.string intrinsics
  func.func private @strlen(!llvm.ptr) -> i64
  func.func private @strcmp(!llvm.ptr, !llvm.ptr) -> i32
  func.func private @atoi(!llvm.ptr) -> i32
  func.func private @atof(!llvm.ptr) -> f64
  // String concatenation runtime (allocates and returns new string)
  func.func private @__cal_strcat(!llvm.ptr, !llvm.ptr) -> !llvm.ptr

  // Random number generation runtime declarations
  func.func private @__cal_srand(i64) -> ()
  func.func private @__cal_rand_f32() -> f32
  func.func private @__cal_rand_f64() -> f64
  func.func private @__cal_randn_f32() -> f32
  func.func private @__cal_randn_f64() -> f64
  func.func private @__cal_rand_range_f32(f32, f32) -> f32
  func.func private @__cal_rand_range_f64(f64, f64) -> f64
  func.func private @__cal_randn_params_f32(f32, f32) -> f32
  func.func private @__cal_randn_params_f64(f64, f64) -> f64
  func.func private @__cal_rand_i32() -> i32
  func.func private @__cal_rand_int_range(i32) -> i32

  func.func @jpeg_decoder_parallel_parser__fn_lshift(%x: i32, %y: i32) -> i32 attributes { cal.ns = "jpeg.decoder.parallel.parser" } {
    %t0 = arith.shli %x, %y : i32 loc(#loc0)
    return %t0 : i32
  }
  func.func @jpeg_decoder_parallel_idct__fn_rshift(%x: i32, %y: i32) -> i32 attributes { cal.ns = "jpeg.decoder.parallel.idct" } {
    %t0 = arith.shrsi %x, %y : i32 loc(#loc1)
    return %t0 : i32
  }
  cal.network @jpeg__Top_JPEG_Decoder_Parallel()
  {
    %t0 = arith.constant 300 : i32 loc(#loc2)
    %source = cal.instantiate @jpeg_io__Source__v__frames_300 (%t0 : i32) instance("source") {cal.instance_name = "source", cal.class_name = "@jpeg_io__Source__v__frames_300"} : !cal.instance<@jpeg_io__Source__v__frames_300>
    %decoder = cal.instantiate @jpeg_decoder_parallel__JpegDecoderParallel instance("decoder") {cal.instance_name = "decoder", cal.class_name = "@jpeg_decoder_parallel__JpegDecoderParallel"} : !cal.instance<@jpeg_decoder_parallel__JpegDecoderParallel>
    %display = cal.instantiate @jpeg_io__Display instance("display") {cal.instance_name = "display", cal.class_name = "@jpeg_io__Display"} : !cal.instance<@jpeg_io__Display>
    cal.connect %source : !cal.instance<@jpeg_io__Source__v__frames_300> "Out" -> %decoder : !cal.instance<@jpeg_decoder_parallel__JpegDecoderParallel> "BYTE" capacity(65536)
    cal.connect %decoder : !cal.instance<@jpeg_decoder_parallel__JpegDecoderParallel> "YCbCr" -> %display : !cal.instance<@jpeg_io__Display> "In" capacity(65536)
    cal.connect %decoder : !cal.instance<@jpeg_decoder_parallel__JpegDecoderParallel> "SOI" -> %display : !cal.instance<@jpeg_io__Display> "SOI" capacity(65536)
  }
  cal.network @jpeg_decoder_parallel__JpegDecoderParallel()
    in_names ["BYTE"]
    out_names ["SOI", "YCbCr"]
    ports_in(%BYTE: !fifo.output_port<i8>)
    ports_out(%SOI: !fifo.input_port<i16>, %YCbCr: !fifo.input_port<i8>)
  {
    %parser = cal.instantiate @jpeg_decoder_parallel_parser__Parser instance("parser") {cal.instance_name = "parser", cal.class_name = "@jpeg_decoder_parallel_parser__Parser"} : !cal.instance<@jpeg_decoder_parallel_parser__Parser>
    %huffman = cal.instantiate @jpeg_decoder_parallel_huffman__Huffman420 instance("huffman") {cal.instance_name = "huffman", cal.class_name = "@jpeg_decoder_parallel_huffman__Huffman420"} : !cal.instance<@jpeg_decoder_parallel_huffman__Huffman420>
    %splitter420 = cal.instantiate @jpeg_decoder_parallel__Splitter420 instance("splitter420") {cal.instance_name = "splitter420", cal.class_name = "@jpeg_decoder_parallel__Splitter420"} : !cal.instance<@jpeg_decoder_parallel__Splitter420>
    %t0 = arith.constant 0 : i32 loc(#loc3)
    %idct_Y = cal.instantiate @jpeg_decoder_parallel_idct__IDCT2D (%t0 : i32) instance("idct_Y") {cal.instance_name = "idct_Y", cal.class_name = "@jpeg_decoder_parallel_idct__IDCT2D"} : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D>
    %t1 = arith.constant 1 : i32 loc(#loc4)
    %idct_Cb = cal.instantiate @jpeg_decoder_parallel_idct__IDCT2D (%t1 : i32) instance("idct_Cb") {cal.instance_name = "idct_Cb", cal.class_name = "@jpeg_decoder_parallel_idct__IDCT2D"} : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D>
    %t2 = arith.constant 2 : i32 loc(#loc5)
    %idct_Cr = cal.instantiate @jpeg_decoder_parallel_idct__IDCT2D (%t2 : i32) instance("idct_Cr") {cal.instance_name = "idct_Cr", cal.class_name = "@jpeg_decoder_parallel_idct__IDCT2D"} : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D>
    %t3 = arith.constant 4 : i32 loc(#loc6)
    %iq_Y = cal.instantiate @jpeg_decoder_parallel_dequant__Dequant__v__mb_4 (%t3 : i32) instance("iq_Y") {cal.instance_name = "iq_Y", cal.class_name = "@jpeg_decoder_parallel_dequant__Dequant__v__mb_4"} : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_4>
    %t4 = arith.constant 1 : i32 loc(#loc7)
    %iq_Cb = cal.instantiate @jpeg_decoder_parallel_dequant__Dequant__v__mb_1 (%t4 : i32) instance("iq_Cb") {cal.instance_name = "iq_Cb", cal.class_name = "@jpeg_decoder_parallel_dequant__Dequant__v__mb_1"} : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1>
    %t5 = arith.constant 1 : i32 loc(#loc8)
    %iq_Cr = cal.instantiate @jpeg_decoder_parallel_dequant__Dequant__v__mb_1 (%t5 : i32) instance("iq_Cr") {cal.instance_name = "iq_Cr", cal.class_name = "@jpeg_decoder_parallel_dequant__Dequant__v__mb_1"} : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1>
    %merger = cal.instantiate @jpeg_decoder_parallel__Merger420 instance("merger") {cal.instance_name = "merger", cal.class_name = "@jpeg_decoder_parallel__Merger420"} : !cal.instance<@jpeg_decoder_parallel__Merger420>
    cal.connect %BYTE : !fifo.output_port<i8> "out" -> %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "Byte" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "Data" -> %huffman : !cal.instance<@jpeg_decoder_parallel_huffman__Huffman420> "Bit" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "HT" -> %huffman : !cal.instance<@jpeg_decoder_parallel_huffman__Huffman420> "HT" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "QT_Y" -> %iq_Y : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_4> "QT" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "QT_UV_1" -> %iq_Cb : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "QT" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "QT_UV_2" -> %iq_Cr : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "QT" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "SOI" -> %SOI : !fifo.input_port<i16> "in" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "SOI" -> %huffman : !cal.instance<@jpeg_decoder_parallel_huffman__Huffman420> "SOI" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "SOI" -> %iq_Y : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_4> "SOI" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "SOI" -> %iq_Cb : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "SOI" capacity(65536)
    cal.connect %parser : !cal.instance<@jpeg_decoder_parallel_parser__Parser> "SOI" -> %iq_Cr : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "SOI" capacity(65536)
    cal.connect %huffman : !cal.instance<@jpeg_decoder_parallel_huffman__Huffman420> "Block" -> %splitter420 : !cal.instance<@jpeg_decoder_parallel__Splitter420> "YCbCr" capacity(65536)
    cal.connect %splitter420 : !cal.instance<@jpeg_decoder_parallel__Splitter420> "Y" -> %iq_Y : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_4> "Block" capacity(65536)
    cal.connect %splitter420 : !cal.instance<@jpeg_decoder_parallel__Splitter420> "Cb" -> %iq_Cb : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "Block" capacity(65536)
    cal.connect %splitter420 : !cal.instance<@jpeg_decoder_parallel__Splitter420> "Cr" -> %iq_Cr : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "Block" capacity(65536)
    cal.connect %iq_Y : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_4> "Out" -> %idct_Y : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "IN" capacity(65536)
    cal.connect %iq_Cb : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "Out" -> %idct_Cb : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "IN" capacity(65536)
    cal.connect %iq_Cr : !cal.instance<@jpeg_decoder_parallel_dequant__Dequant__v__mb_1> "Out" -> %idct_Cr : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "IN" capacity(65536)
    cal.connect %idct_Y : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "OUT" -> %merger : !cal.instance<@jpeg_decoder_parallel__Merger420> "Y" capacity(65536)
    cal.connect %idct_Cb : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "OUT" -> %merger : !cal.instance<@jpeg_decoder_parallel__Merger420> "Cb" capacity(65536)
    cal.connect %idct_Cr : !cal.instance<@jpeg_decoder_parallel_idct__IDCT2D> "OUT" -> %merger : !cal.instance<@jpeg_decoder_parallel__Merger420> "Cr" capacity(65536)
    cal.connect %merger : !cal.instance<@jpeg_decoder_parallel__Merger420> "YCbCr" -> %YCbCr : !fifo.input_port<i8> "in" capacity(65536)
  }
  cal.actor @jpeg_io__Display()
    in_names ["In", "SOI"]
    ports_in(%In: !fifo.output_port<i8>, %SOI: !fifo.output_port<i16>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc9)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t3 = arith.constant 0 : i32 loc(#loc10)
    %t4 = arith.extsi %t3 : i32 to i64
    cal.set(%t2: !cal.state_ref<i64>, %t4: i64)
    cal.action "$untagged0" priority=1 {
      %t5 = memref.alloca() : memref<64xi8>
      %t6 = arith.constant 64 : index
      %t7 = arith.constant 0 : index
      %t8 = arith.constant 1 : index
      scf.for %t9 = %t7 to %t6 step %t8 {
        %t10 = fifo.pop(%In: !fifo.output_port<i8> ) : i8
        memref.store %t10, %t5[%t9] : memref<64xi8>
        scf.yield
      }
      %t11 = arith.constant 0 : i32 loc(#loc12)
      %t12 = arith.constant 63 : i32 loc(#loc13)
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.index_cast %t12 : i32 to index
      %t15 = arith.constant 1 : index
      %t16 = arith.addi %t14, %t15 : index
      scf.for %t17 = %t13 to %t16 step %t15 {
        %t18 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t19 = arith.constant 1 : i32 loc(#loc14)
        %t20 = arith.addi %t18, %t19 : i32 loc(#loc15)
        cal.set(%t0: !cal.state_ref<i32>, %t20: i32)
        %t21 = cal.get(%t2: !cal.state_ref<i64>) : i64
        %t22 = memref.load %t5[%t17] : memref<64xi8> loc(#loc16)
        %t23 = arith.extui %t22 : i8 to i64
        %t24 = arith.addi %t21, %t23 : i64 loc(#loc17)
        cal.set(%t2: !cal.state_ref<i64>, %t24: i64)
        %t25 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t26 = arith.constant 1000000 : i32 loc(#loc18)
        %t27 = arith.remsi %t25, %t26 : i32 loc(#loc19)
        %t28 = arith.constant 0 : i32 loc(#loc20)
        %t29 = arith.cmpi eq, %t27, %t28 : i32 loc(#loc19)
        %t30 = scf.if %t29 -> i1 {
          %t31 = cal.get(%t0: !cal.state_ref<i32>) : i32
          %t32 = cal.get(%t2: !cal.state_ref<i64>) : i64
          fifo.print("Received %i bytes, sum is %llu\n\00", %t31, %t32) : (i32, i64)
          %t33 = arith.constant 0 : i32 loc(#loc21)
          %t34 = arith.extsi %t33 : i32 to i64
          cal.set(%t2: !cal.state_ref<i64>, %t34: i64)
          %t35 = arith.constant 1 : i1
          scf.yield %t35 : i1
        } else {
          %t36 = arith.constant 0 : i1
          scf.yield %t36 : i1
        }
        scf.yield
      }
    } loc(#loc11)
    cal.action "$untagged1" priority=1 {
      %t37 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t38 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
    } loc(#loc22)
  } loc(#loc23)
  cal.network @jpeg_decoder_parallel_parser__Parser()
    in_names ["Byte"]
    out_names ["Data", "QT_Y", "QT_UV_1", "QT_UV_2", "HT", "SOI"]
    ports_in(%Byte: !fifo.output_port<i8>)
    ports_out(%Data: !fifo.input_port<i8>, %QT_Y: !fifo.input_port<i8>, %QT_UV_1: !fifo.input_port<i8>, %QT_UV_2: !fifo.input_port<i8>, %HT: !fifo.input_port<i8>, %SOI: !fifo.input_port<i16>)
  {
    %parse = cal.instantiate @jpeg_decoder_parallel_parser__ParseJPEG instance("parse") {cal.instance_name = "parse", cal.class_name = "@jpeg_decoder_parallel_parser__ParseJPEG"} : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG>
    %splitQT = cal.instantiate @jpeg_decoder_parallel_parser__SplitQT instance("splitQT") {cal.instance_name = "splitQT", cal.class_name = "@jpeg_decoder_parallel_parser__SplitQT"} : !cal.instance<@jpeg_decoder_parallel_parser__SplitQT>
    cal.connect %Byte : !fifo.output_port<i8> "out" -> %parse : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG> "Byte" capacity(65536)
    cal.connect %parse : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG> "Data" -> %Data : !fifo.input_port<i8> "in" capacity(65536)
    cal.connect %parse : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG> "QT" -> %splitQT : !cal.instance<@jpeg_decoder_parallel_parser__SplitQT> "QT" capacity(65536)
    cal.connect %parse : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG> "HT" -> %HT : !fifo.input_port<i8> "in" capacity(65536)
    cal.connect %parse : !cal.instance<@jpeg_decoder_parallel_parser__ParseJPEG> "SOI" -> %SOI : !fifo.input_port<i16> "in" capacity(65536)
    cal.connect %splitQT : !cal.instance<@jpeg_decoder_parallel_parser__SplitQT> "QT_Y" -> %QT_Y : !fifo.input_port<i8> "in" capacity(65536)
    cal.connect %splitQT : !cal.instance<@jpeg_decoder_parallel_parser__SplitQT> "QT_UV_1" -> %QT_UV_1 : !fifo.input_port<i8> "in" capacity(65536)
    cal.connect %splitQT : !cal.instance<@jpeg_decoder_parallel_parser__SplitQT> "QT_UV_2" -> %QT_UV_2 : !fifo.input_port<i8> "in" capacity(65536)
  }
  cal.actor @jpeg_decoder_parallel_huffman__Huffman420()
    in_names ["Bit", "HT", "SOI"]
    out_names ["Block"]
    ports_in(%Bit: !fifo.output_port<i8>, %HT: !fifo.output_port<i8>, %SOI: !fifo.output_port<i16>)
    ports_out(%Block: !fifo.input_port<i24>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc24)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i16> : !cal.state_ref<i16>
    %t3 = arith.constant 0 : i32 loc(#loc25)
    %t4 = arith.trunci %t3 : i32 to i16
    cal.set(%t2: !cal.state_ref<i16>, %t4: i16)
    %t5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t6 = arith.constant 0 : i32 loc(#loc26)
    cal.set(%t5: !cal.state_ref<i32>, %t6: i32)
    %t7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t8 = arith.constant 0 : i32 loc(#loc27)
    cal.set(%t7: !cal.state_ref<i32>, %t8: i32)
    %t9 = cal.create_state_var<i8> : !cal.state_ref<i8>
    %t10 = arith.constant 0 : i32 loc(#loc28)
    %t11 = arith.trunci %t10 : i32 to i8
    cal.set(%t9: !cal.state_ref<i8>, %t11: i8)
    %t12 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t13 = arith.constant 0 : i32 loc(#loc29)
    cal.set(%t12: !cal.state_ref<i32>, %t13: i32)
    %t14 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t15 = arith.constant 0 : i32 loc(#loc30)
    cal.set(%t14: !cal.state_ref<i32>, %t15: i32)
    %t16 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t17 = arith.constant 0 : i32 loc(#loc31)
    cal.set(%t16: !cal.state_ref<i32>, %t17: i32)
    %t18 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t19 = arith.constant 0 : i32 loc(#loc32)
    cal.set(%t18: !cal.state_ref<i32>, %t19: i32)
    %t20 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t21 = arith.constant 0 : i32 loc(#loc33)
    cal.set(%t20: !cal.state_ref<i32>, %t21: i32)
    %t22 = cal.create_state_var<i8> : !cal.state_ref<i8>
    %t23 = arith.constant 0 : i32 loc(#loc34)
    %t24 = arith.trunci %t23 : i32 to i8
    cal.set(%t22: !cal.state_ref<i8>, %t24: i8)
    %t25 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t26 = arith.constant 0 : i32 loc(#loc35)
    %t27 = arith.extsi %t26 : i32 to i64
    cal.set(%t25: !cal.state_ref<i64>, %t27: i64)
    %t28 = cal.create_state_var<memref<3xi8>> : !cal.state_ref<memref<3xi8>>
    %t29 = cal.get(%t28: !cal.state_ref<memref<3xi8>>) : memref<3xi8>
    %t30 = memref.get_global @__cmr_0 : memref<3xi8>
    memref.copy %t30, %t29 : memref<3xi8> to memref<3xi8>
    %t31 = cal.create_state_var<memref<3xi8>> : !cal.state_ref<memref<3xi8>>
    %t32 = cal.get(%t31: !cal.state_ref<memref<3xi8>>) : memref<3xi8>
    %t33 = memref.get_global @__cmr_1 : memref<3xi8>
    memref.copy %t33, %t32 : memref<3xi8> to memref<3xi8>
    %t34 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %t35 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t36 = arith.constant 256 : i32 loc(#loc36)
    cal.set(%t35: !cal.state_ref<i32>, %t36: i32)
    %t37 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %t38 = cal.create_state_var<memref<4x256xi32>> : !cal.state_ref<memref<4x256xi32>>
    %t39 = cal.create_state_var<memref<16xi8>> : !cal.state_ref<memref<16xi8>>
    %t40 = cal.create_state_var<memref<256xi8>> : !cal.state_ref<memref<256xi8>>
    %t41 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t42 = arith.constant 0 : i32 loc(#loc37)
    cal.set(%t41: !cal.state_ref<i32>, %t42: i32)
    %t43 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t44 = arith.constant 0 : i32 loc(#loc38)
    cal.set(%t43: !cal.state_ref<i32>, %t44: i32)
    %t45 = cal.create_state_var<memref<3xi32>> : !cal.state_ref<memref<3xi32>>
    %t46 = cal.get(%t45: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
    %t47 = memref.get_global @__cmr_2 : memref<3xi32>
    memref.copy %t47, %t46 : memref<3xi32> to memref<3xi32>
    %t48 = cal.create_state_var<memref<3xi32>> : !cal.state_ref<memref<3xi32>>
    %t49 = cal.create_state_var<memref<64xi24>> : !cal.state_ref<memref<64xi24>>
    cal.fsm {
      cal.state @waitSOI {
        cal.transition action("getSOI") -> @wait_HT
      } { initial }
      cal.state @wait_AC {
        cal.transition action("EOB") -> @wait_DC_len
        cal.transition action("getbit.read") -> @wait_AC
        cal.transition action("getbit.noread") -> @wait_AC
        cal.transition action("AC.done") -> @wait_AC_len
      }
      cal.state @wait_AC_len {
        cal.transition action("getbit.read") -> @wait_AC_len
        cal.transition action("getbit.noread") -> @wait_AC_len
        cal.transition action("AC.done_len") -> @wait_AC
      }
      cal.state @wait_DC {
        cal.transition action("getbit.read") -> @wait_DC
        cal.transition action("getbit.noread") -> @wait_DC
        cal.transition action("DC.done") -> @wait_AC_len
      }
      cal.state @wait_DC_len {
        cal.transition action("EOI") -> @waitSOI
        cal.transition action("getbit.read") -> @wait_DC_len
        cal.transition action("getbit.noread") -> @wait_DC_len
        cal.transition action("DC.done_len") -> @wait_DC
      }
      cal.state @wait_HT {
        cal.transition action("receive_HT_len") -> @wait_code
        cal.transition action("done_HT") -> @wait_DC_len
      }
      cal.state @wait_code {
        cal.transition action("receive_code") -> @wait_code
        cal.transition action("build_HT") -> @wait_HT
      }
    }
    cal.action "getbit.read" priority=11 {
      cal.predicate {
        %t50 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t51 = arith.constant 0 : i32 loc(#loc40)
        %t52 = arith.cmpi ne, %t50, %t51 : i32 loc(#loc41)
        %t53 = cal.get(%t20: !cal.state_ref<i32>) : i32
        %t54 = arith.constant 0 : i32 loc(#loc42)
        %t55 = arith.cmpi eq, %t53, %t54 : i32 loc(#loc43)
        %t56 = scf.if %t52 -> i1 {
          scf.yield %t55 : i1
        } else {
          %t57 = arith.constant 0 : i1
          scf.yield %t57 : i1
        }
        cal.predicate_result %t56 : i1
      }
      %t58 = fifo.pop(%Bit: !fifo.output_port<i8> ) : i8
      cal.set(%t22: !cal.state_ref<i8>, %t58: i8)
      %t59 = arith.constant 2 : i32 loc(#loc44)
      %t60 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t61 = arith.extui %t60 : i16 to i32
      %t63 = arith.extsi %t59 : i32 to i64
      %t64 = arith.extui %t61 : i32 to i64
      %t62 = arith.muli %t63, %t64 : i64 loc(#loc44)
      %t65 = arith.constant 0 : i1
      %t66 = cal.get(%t22: !cal.state_ref<i8>) : i8
      %t67 = arith.constant 7 : i32 loc(#loc45)
      %t68 = cal.get(%t20: !cal.state_ref<i32>) : i32
      %t69 = arith.subi %t67, %t68 : i32 loc(#loc45)
      %t70 = arith.extui %t66 : i8 to i32
      %t71 = arith.shrsi %t70, %t69 : i32 loc(#loc46)
      %t72 = arith.constant 1 : i32 loc(#loc47)
      %t73 = arith.andi %t71, %t72 : i32 loc(#loc48)
      %t74 = arith.trunci %t73 : i32 to i1
      %t75 = arith.extui %t74 : i1 to i64
      %t76 = arith.addi %t62, %t75 : i64 loc(#loc44)
      %t77 = arith.trunci %t76 : i64 to i16
      cal.set(%t2: !cal.state_ref<i16>, %t77: i16)
      %t78 = cal.get(%t7: !cal.state_ref<i32>) : i32
      %t79 = arith.constant 1 : i32 loc(#loc49)
      %t80 = arith.subi %t78, %t79 : i32 loc(#loc50)
      cal.set(%t7: !cal.state_ref<i32>, %t80: i32)
      %t81 = cal.get(%t5: !cal.state_ref<i32>) : i32
      %t82 = arith.constant 1 : i32 loc(#loc51)
      %t83 = arith.addi %t81, %t82 : i32 loc(#loc52)
      cal.set(%t5: !cal.state_ref<i32>, %t83: i32)
      %t84 = cal.get(%t20: !cal.state_ref<i32>) : i32
      %t85 = arith.constant 1 : i32 loc(#loc53)
      %t86 = arith.addi %t84, %t85 : i32 loc(#loc54)
      %t87 = arith.constant 7 : i32 loc(#loc55)
      %t88 = arith.andi %t86, %t87 : i32 loc(#loc54)
      cal.set(%t20: !cal.state_ref<i32>, %t88: i32)
    } loc(#loc39)
    cal.action "getbit.noread" priority=12 {
      cal.predicate {
        %t89 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t90 = arith.constant 0 : i32 loc(#loc57)
        %t91 = arith.cmpi ne, %t89, %t90 : i32 loc(#loc58)
        %t92 = cal.get(%t20: !cal.state_ref<i32>) : i32
        %t93 = arith.constant 0 : i32 loc(#loc59)
        %t94 = arith.cmpi ne, %t92, %t93 : i32 loc(#loc60)
        %t95 = scf.if %t91 -> i1 {
          scf.yield %t94 : i1
        } else {
          %t96 = arith.constant 0 : i1
          scf.yield %t96 : i1
        }
        cal.predicate_result %t95 : i1
      }
      %t97 = arith.constant 2 : i32 loc(#loc61)
      %t98 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t99 = arith.extui %t98 : i16 to i32
      %t101 = arith.extsi %t97 : i32 to i64
      %t102 = arith.extui %t99 : i32 to i64
      %t100 = arith.muli %t101, %t102 : i64 loc(#loc61)
      %t103 = arith.constant 0 : i1
      %t104 = cal.get(%t22: !cal.state_ref<i8>) : i8
      %t105 = arith.constant 7 : i32 loc(#loc45)
      %t106 = cal.get(%t20: !cal.state_ref<i32>) : i32
      %t107 = arith.subi %t105, %t106 : i32 loc(#loc45)
      %t108 = arith.extui %t104 : i8 to i32
      %t109 = arith.shrsi %t108, %t107 : i32 loc(#loc46)
      %t110 = arith.constant 1 : i32 loc(#loc47)
      %t111 = arith.andi %t109, %t110 : i32 loc(#loc48)
      %t112 = arith.trunci %t111 : i32 to i1
      %t113 = arith.extui %t112 : i1 to i64
      %t114 = arith.addi %t100, %t113 : i64 loc(#loc61)
      %t115 = arith.trunci %t114 : i64 to i16
      cal.set(%t2: !cal.state_ref<i16>, %t115: i16)
      %t116 = cal.get(%t7: !cal.state_ref<i32>) : i32
      %t117 = arith.constant 1 : i32 loc(#loc62)
      %t118 = arith.subi %t116, %t117 : i32 loc(#loc63)
      cal.set(%t7: !cal.state_ref<i32>, %t118: i32)
      %t119 = cal.get(%t5: !cal.state_ref<i32>) : i32
      %t120 = arith.constant 1 : i32 loc(#loc64)
      %t121 = arith.addi %t119, %t120 : i32 loc(#loc65)
      cal.set(%t5: !cal.state_ref<i32>, %t121: i32)
      %t122 = cal.get(%t20: !cal.state_ref<i32>) : i32
      %t123 = arith.constant 1 : i32 loc(#loc53)
      %t124 = arith.addi %t122, %t123 : i32 loc(#loc54)
      %t125 = arith.constant 7 : i32 loc(#loc55)
      %t126 = arith.andi %t124, %t125 : i32 loc(#loc54)
      cal.set(%t20: !cal.state_ref<i32>, %t126: i32)
    } loc(#loc56)
    cal.action "getSOI" priority=12 {
      %t127 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t128 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t129 = arith.constant 6 : i32 loc(#loc67)
      %t130 = arith.extui %t127 : i16 to i32
      %t132 = arith.extsi %t129 : i32 to i64
      %t133 = arith.extui %t130 : i32 to i64
      %t131 = arith.muli %t132, %t133 : i64 loc(#loc67)
      %t134 = arith.extui %t128 : i16 to i64
      %t135 = arith.muli %t131, %t134 : i64 loc(#loc67)
      %t136 = arith.trunci %t135 : i64 to i32
      cal.set(%t18: !cal.state_ref<i32>, %t136: i32)
      %t137 = arith.constant 0 : i32 loc(#loc68)
      %t138 = arith.constant 2 : i32 loc(#loc69)
      %t139 = arith.index_cast %t137 : i32 to index
      %t140 = arith.index_cast %t138 : i32 to index
      %t141 = arith.constant 1 : index
      %t142 = arith.addi %t140, %t141 : index
      scf.for %t143 = %t139 to %t142 step %t141 {
        %t144 = cal.get(%t48: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
        %t145 = arith.constant 0 : i32 loc(#loc70)
        memref.store %t145, %t144[%t143] : memref<3xi32>
        scf.yield
      }
    } loc(#loc66)
    cal.action "receive_HT_len" priority=11 {
      %t146 = arith.constant 0 : i32 loc(#loc72)
      %t147 = memref.alloca() : memref<17xi8>
      %t148 = arith.constant 17 : index
      %t149 = arith.constant 0 : index
      %t150 = arith.constant 1 : index
      scf.for %t151 = %t149 to %t148 step %t150 {
        %t152 = fifo.pop(%HT: !fifo.output_port<i8> ) : i8
        memref.store %t152, %t147[%t151] : memref<17xi8>
        scf.yield
      }
      %t153 = arith.constant 0 : i32 loc(#loc73)
      cal.set(%t12: !cal.state_ref<i32>, %t153: i32)
      %t154 = arith.constant 0 : i32 loc(#loc74)
      %t155 = arith.index_cast %t154 : i32 to index
      %t156 = memref.load %t147[%t155] : memref<17xi8> loc(#loc75)
      %t157 = arith.constant 0 : i32 loc(#loc76)
      %t158 = arith.index_cast %t157 : i32 to index
      %t159 = memref.load %t147[%t158] : memref<17xi8> loc(#loc77)
      %t160 = arith.constant 3 : i32 loc(#loc78)
      %t161 = arith.extui %t159 : i8 to i32
      %t162 = arith.shrsi %t161, %t160 : i32 loc(#loc79)
      %t163 = arith.extui %t156 : i8 to i32
      %t164 = arith.ori %t163, %t162 : i32 loc(#loc80)
      %t165 = arith.constant 3 : i32 loc(#loc81)
      %t166 = arith.andi %t164, %t165 : i32 loc(#loc80)
      %t167 = arith.trunci %t166 : i32 to i8
      cal.set(%t9: !cal.state_ref<i8>, %t167: i8)
      %t168 = arith.constant 0 : i32 loc(#loc82)
      %t169 = arith.constant 15 : i32 loc(#loc83)
      %t170 = arith.index_cast %t168 : i32 to index
      %t171 = arith.index_cast %t169 : i32 to index
      %t172 = arith.constant 1 : index
      %t173 = arith.addi %t171, %t172 : index
      %t175 = scf.for %t174 = %t170 to %t173 step %t172 iter_args(%t176 = %t146) -> (i32) {
        %t177 = cal.get(%t39: !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %t178 = arith.constant 1 : i32 loc(#loc84)
        %t179 = arith.index_cast %t174 : index to i32
        %t180 = arith.addi %t179, %t178 : i32 loc(#loc85)
        %t181 = arith.index_cast %t180 : i32 to index
        %t182 = memref.load %t147[%t181] : memref<17xi8> loc(#loc86)
        memref.store %t182, %t177[%t174] : memref<16xi8>
        %t183 = cal.get(%t39: !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %t184 = memref.load %t183[%t174] : memref<16xi8> loc(#loc87)
        %t185 = arith.extui %t184 : i8 to i32
        %t186 = arith.addi %t176, %t185 : i32 loc(#loc88)
        scf.yield %t186 : i32
      }
      cal.set(%t7: !cal.state_ref<i32>, %t175: i32)
    } loc(#loc71)
    cal.action "receive_code" priority=12 {
      cal.predicate {
        %t187 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t188 = arith.constant 0 : i32 loc(#loc90)
        %t189 = arith.cmpi ugt, %t187, %t188 : i32 loc(#loc91)
        cal.predicate_result %t189 : i1
      }
      %t190 = fifo.pop(%HT: !fifo.output_port<i8> ) : i8
      %t191 = cal.get(%t12: !cal.state_ref<i32>) : i32
      %t192 = arith.index_cast %t191 : i32 to index
      %t193 = cal.get(%t40: !cal.state_ref<memref<256xi8>>) : memref<256xi8>
      memref.store %t190, %t193[%t192] : memref<256xi8>
      %t194 = cal.get(%t12: !cal.state_ref<i32>) : i32
      %t195 = arith.constant 1 : i32 loc(#loc92)
      %t196 = arith.addi %t194, %t195 : i32 loc(#loc93)
      cal.set(%t12: !cal.state_ref<i32>, %t196: i32)
      %t197 = cal.get(%t7: !cal.state_ref<i32>) : i32
      %t198 = arith.constant 1 : i32 loc(#loc94)
      %t199 = arith.subi %t197, %t198 : i32 loc(#loc95)
      cal.set(%t7: !cal.state_ref<i32>, %t199: i32)
    } loc(#loc89)
    cal.action "build_HT" priority=12 {
      cal.predicate {
        %t200 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t201 = arith.constant 0 : i32 loc(#loc97)
        %t202 = arith.cmpi eq, %t200, %t201 : i32 loc(#loc98)
        cal.predicate_result %t202 : i1
      }
      %t203 = arith.constant 0 : i32
      %t204 = arith.constant 0 : i32
      %t205 = arith.constant 0 : i32
      %t206 = arith.constant 0 : i32
      %t207 = arith.constant 0 : i32
      %t208 = arith.constant 0 : i32 loc(#loc99)
      %t209 = arith.constant 0 : i32 loc(#loc100)
      %t210 = arith.constant 0 : i32 loc(#loc101)
      %t211 = arith.constant 32768 : i32 loc(#loc102)
      %t212 = arith.constant 0 : i32 loc(#loc103)
      %t213 = arith.constant 15 : i32 loc(#loc104)
      %t214 = arith.index_cast %t212 : i32 to index
      %t215 = arith.index_cast %t213 : i32 to index
      %t216 = arith.constant 1 : index
      %t217 = arith.addi %t215, %t216 : index
      %t219, %t220, %t221, %t222, %t223 = scf.for %t218 = %t214 to %t217 step %t216 iter_args(%t224 = %t204, %t225 = %t208, %t226 = %t209, %t227 = %t210, %t228 = %t211) -> (i32, i32, i32, i32, i32) {
        %t229 = arith.constant 1 : i32 loc(#loc105)
        %t230 = arith.index_cast %t218 : index to i32
        %t231 = arith.addi %t230, %t229 : i32 loc(#loc106)
        %t232 = arith.constant 0 : i32 loc(#loc107)
        %t233 = cal.get(%t39: !cal.state_ref<memref<16xi8>>) : memref<16xi8>
        %t234 = memref.load %t233[%t218] : memref<16xi8> loc(#loc108)
        %t235 = arith.constant 1 : i32 loc(#loc109)
        %t236 = arith.extui %t234 : i8 to i32
        %t237 = arith.subi %t236, %t235 : i32 loc(#loc108)
        %t238 = arith.index_cast %t232 : i32 to index
        %t239 = arith.index_cast %t237 : i32 to index
        %t240 = arith.constant 1 : index
        %t241 = arith.addi %t239, %t240 : index
        %t243, %t244, %t245 = scf.for %t242 = %t238 to %t241 step %t240 iter_args(%t246 = %t225, %t247 = %t226, %t248 = %t227) -> (i32, i32, i32) {
          %t249 = cal.get(%t9: !cal.state_ref<i8>) : i8
          %t250 = arith.extui %t249 : i8 to i32
          %t251 = arith.index_cast %t250 : i32 to index
          %t252 = cal.get(%t40: !cal.state_ref<memref<256xi8>>) : memref<256xi8>
          %t253 = arith.index_cast %t248 : i32 to index
          %t254 = memref.load %t252[%t253] : memref<256xi8> loc(#loc110)
          %t255 = arith.extui %t254 : i8 to i32
          %t256 = arith.index_cast %t255 : i32 to index
          %t257 = cal.get(%t34: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          memref.store %t231, %t257[%t251, %t256] : memref<4x256xi32>
          %t258 = cal.get(%t9: !cal.state_ref<i8>) : i8
          %t259 = arith.extui %t258 : i8 to i32
          %t260 = arith.index_cast %t259 : i32 to index
          %t261 = arith.index_cast %t246 : i32 to index
          %t262 = cal.get(%t37: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          memref.store %t247, %t262[%t260, %t261] : memref<4x256xi32>
          %t263 = cal.get(%t9: !cal.state_ref<i8>) : i8
          %t264 = arith.extui %t263 : i8 to i32
          %t265 = arith.index_cast %t264 : i32 to index
          %t266 = arith.index_cast %t246 : i32 to index
          %t267 = cal.get(%t38: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
          %t268 = cal.get(%t40: !cal.state_ref<memref<256xi8>>) : memref<256xi8>
          %t269 = arith.index_cast %t248 : i32 to index
          %t270 = memref.load %t268[%t269] : memref<256xi8> loc(#loc111)
          %t271 = arith.extui %t270 : i8 to i32
          memref.store %t271, %t267[%t265, %t266] : memref<4x256xi32>
          %t272 = arith.constant 1 : i32 loc(#loc112)
          %t273 = arith.addi %t246, %t272 : i32 loc(#loc113)
          %t274 = arith.addi %t247, %t228 : i32 loc(#loc114)
          %t275 = arith.constant 1 : i32 loc(#loc115)
          %t276 = arith.addi %t248, %t275 : i32 loc(#loc116)
          scf.yield %t273, %t274, %t276 : i32, i32, i32
        }
        %t277 = arith.constant 1 : i32 loc(#loc117)
        %t278 = arith.shrsi %t228, %t277 : i32 loc(#loc118)
        scf.yield %t231, %t243, %t244, %t245, %t278 : i32, i32, i32, i32, i32
      }
      %t279 = cal.get(%t9: !cal.state_ref<i8>) : i8
      %t280 = arith.extui %t279 : i8 to i32
      %t281 = arith.index_cast %t280 : i32 to index
      %t282 = arith.index_cast %t220 : i32 to index
      %t283 = cal.get(%t37: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %t284 = arith.constant 1000000000 : i32 loc(#loc119)
      memref.store %t284, %t283[%t281, %t282] : memref<4x256xi32>
      %t285 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t286 = arith.constant 1 : i32 loc(#loc120)
      %t287 = arith.addi %t285, %t286 : i32 loc(#loc121)
      cal.set(%t0: !cal.state_ref<i32>, %t287: i32)
    } loc(#loc96)
    cal.action "done_HT" priority=12 {
      cal.predicate {
        %t288 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t289 = arith.constant 4 : i32 loc(#loc123)
        %t290 = arith.cmpi eq, %t288, %t289 : i32 loc(#loc124)
        cal.predicate_result %t290 : i1
      }
      %t291 = arith.constant 65535 : i32 loc(#loc125)
      cal.set(%t14: !cal.state_ref<i32>, %t291: i32)
      %t292 = arith.constant 0 : i32 loc(#loc126)
      cal.set(%t43: !cal.state_ref<i32>, %t292: i32)
      %t293 = cal.get(%t28: !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %t294 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t295 = arith.index_cast %t294 : i32 to index
      %t296 = memref.load %t293[%t295] : memref<3xi8> loc(#loc127)
      cal.set(%t9: !cal.state_ref<i8>, %t296: i8)
      %t297 = arith.constant 0 : i32 loc(#loc128)
      %t298 = arith.trunci %t297 : i32 to i16
      cal.set(%t2: !cal.state_ref<i16>, %t298: i16)
      %t299 = arith.constant 0 : i32 loc(#loc129)
      cal.set(%t5: !cal.state_ref<i32>, %t299: i32)
      %t300 = arith.constant 16 : i32 loc(#loc130)
      cal.set(%t7: !cal.state_ref<i32>, %t300: i32)
    } loc(#loc122)
    cal.action "DC.done_len" priority=10 {
      cal.predicate {
        %t301 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t302 = arith.constant 0 : i32 loc(#loc132)
        %t303 = arith.cmpi eq, %t301, %t302 : i32 loc(#loc133)
        cal.predicate_result %t303 : i1
      }
      %t304 = cal.get(%t9: !cal.state_ref<i8>) : i8
      %t305 = arith.extui %t304 : i8 to i32
      %t306 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t307 = arith.constant 0 : i32 loc(#loc134)
      %t308 = scf.while (%arg0 = %t307) : (i32) -> (i32) {
        %t309 = cal.get(%t37: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
        %t310 = arith.index_cast %t305 : i32 to index
        %t311 = arith.index_cast %arg0 : i32 to index
        %t312 = memref.load %t309[%t310, %t311] : memref<4x256xi32> loc(#loc135)
        %t313 = arith.extui %t306 : i16 to i32
        %t314 = arith.cmpi uge, %t313, %t312 : i32 loc(#loc136)
        scf.condition(%t314) %arg0 : i32
      } do {
        ^bb0(%t315: i32):
        %t316 = arith.constant 1 : i32 loc(#loc137)
        %t317 = arith.addi %t315, %t316 : i32 loc(#loc138)
        scf.yield %t317 : i32
      }
      %t318 = cal.get(%t38: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %t319 = arith.index_cast %t305 : i32 to index
      %t320 = arith.constant 1 : i32 loc(#loc140)
      %t321 = arith.subi %t308, %t320 : i32 loc(#loc141)
      %t322 = arith.index_cast %t321 : i32 to index
      %t323 = memref.load %t318[%t319, %t322] : memref<4x256xi32> loc(#loc139)
      cal.set(%t14: !cal.state_ref<i32>, %t323: i32)
      %t324 = cal.get(%t34: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %t325 = cal.get(%t9: !cal.state_ref<i8>) : i8
      %t326 = arith.extui %t325 : i8 to i32
      %t327 = arith.index_cast %t326 : i32 to index
      %t328 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t329 = arith.index_cast %t328 : i32 to index
      %t330 = memref.load %t324[%t327, %t329] : memref<4x256xi32> loc(#loc142)
      cal.set(%t7: !cal.state_ref<i32>, %t330: i32)
      %t331 = cal.get(%t7: !cal.state_ref<i32>) : i32
      cal.set(%t5: !cal.state_ref<i32>, %t331: i32)
    } loc(#loc131)
    cal.action "DC.done" priority=12 {
      cal.predicate {
        %t332 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t333 = arith.constant 0 : i32 loc(#loc144)
        %t334 = arith.cmpi eq, %t332, %t333 : i32 loc(#loc145)
        cal.predicate_result %t334 : i1
      }
      %t335 = arith.constant 0 : i32
      %t336 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t337 = arith.constant 15 : i32 loc(#loc146)
      %t338 = arith.andi %t336, %t337 : i32 loc(#loc147)
      cal.set(%t7: !cal.state_ref<i32>, %t338: i32)
      %t339 = cal.get(%t7: !cal.state_ref<i32>) : i32
      cal.set(%t5: !cal.state_ref<i32>, %t339: i32)
      %t340 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t341 = arith.constant 16 : i32 loc(#loc148)
      %t342 = cal.get(%t7: !cal.state_ref<i32>) : i32
      %t343 = arith.subi %t341, %t342 : i32 loc(#loc149)
      %t344 = arith.extui %t340 : i16 to i32
      %t345 = arith.shrsi %t344, %t343 : i32 loc(#loc150)
      %t346 = arith.constant 1 : i32 loc(#loc151)
      %t347 = cal.get(%t5: !cal.state_ref<i32>) : i32
      %t348 = arith.constant 1 : i32 loc(#loc152)
      %t349 = arith.subi %t347, %t348 : i32 loc(#loc153)
      %t350 = arith.shli %t346, %t349 : i32 loc(#loc154)
      %t351 = arith.cmpi slt, %t345, %t350 : i32 loc(#loc155)
      %t352 = scf.if %t351 -> i32 {
        %t353 = arith.constant 1 : i32 loc(#loc156)
        %t354 = arith.constant 0 : i32 loc(#loc157)
        %t355 = arith.subi %t354, %t353 : i32 loc(#loc157)
        %t356 = cal.get(%t5: !cal.state_ref<i32>) : i32
        %t357 = arith.shli %t355, %t356 : i32 loc(#loc158)
        %t358 = arith.addi %t345, %t357 : i32 loc(#loc159)
        %t359 = arith.constant 1 : i32 loc(#loc160)
        %t360 = arith.addi %t358, %t359 : i32 loc(#loc159)
        scf.yield %t360 : i32
      } else {
        scf.yield %t345 : i32
      }
      %t361 = cal.get(%t48: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      %t362 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t363 = arith.index_cast %t362 : i32 to index
      %t364 = memref.load %t361[%t363] : memref<3xi32> loc(#loc161)
      %t365 = arith.addi %t352, %t364 : i32 loc(#loc162)
      %t366 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t367 = arith.index_cast %t366 : i32 to index
      %t368 = cal.get(%t48: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      memref.store %t365, %t368[%t367] : memref<3xi32>
      %t369 = arith.constant 0 : i32 loc(#loc163)
      cal.set(%t5: !cal.state_ref<i32>, %t369: i32)
      %t370 = cal.get(%t31: !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %t371 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t372 = arith.index_cast %t371 : i32 to index
      %t373 = memref.load %t370[%t372] : memref<3xi8> loc(#loc164)
      cal.set(%t9: !cal.state_ref<i8>, %t373: i8)
      %t374 = arith.constant 0 : i32 loc(#loc165)
      %t375 = arith.constant 63 : i32 loc(#loc166)
      %t376 = arith.index_cast %t374 : i32 to index
      %t377 = arith.index_cast %t375 : i32 to index
      %t378 = arith.constant 1 : index
      %t379 = arith.addi %t377, %t378 : index
      scf.for %t380 = %t376 to %t379 step %t378 {
        %t381 = cal.get(%t49: !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        %t382 = arith.constant 0 : i32 loc(#loc167)
        %t383 = arith.trunci %t382 : i32 to i24
        memref.store %t383, %t381[%t380] : memref<64xi24>
        scf.yield
      }
      %t384 = arith.constant 0 : i32 loc(#loc168)
      cal.set(%t12: !cal.state_ref<i32>, %t384: i32)
      %t385 = arith.constant 0 : i32 loc(#loc169)
      %t386 = arith.index_cast %t385 : i32 to index
      %t387 = cal.get(%t49: !cal.state_ref<memref<64xi24>>) : memref<64xi24>
      %t388 = arith.trunci %t365 : i32 to i24
      memref.store %t388, %t387[%t386] : memref<64xi24>
    } loc(#loc143)
    cal.action "AC.done_len" priority=12 {
      cal.predicate {
        %t389 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t390 = arith.constant 0 : i32 loc(#loc171)
        %t391 = arith.cmpi eq, %t389, %t390 : i32 loc(#loc172)
        cal.predicate_result %t391 : i1
      }
      %t392 = cal.get(%t9: !cal.state_ref<i8>) : i8
      %t393 = arith.extui %t392 : i8 to i32
      %t394 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t395 = arith.constant 0 : i32 loc(#loc134)
      %t396 = scf.while (%arg0 = %t395) : (i32) -> (i32) {
        %t397 = cal.get(%t37: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
        %t398 = arith.index_cast %t393 : i32 to index
        %t399 = arith.index_cast %arg0 : i32 to index
        %t400 = memref.load %t397[%t398, %t399] : memref<4x256xi32> loc(#loc135)
        %t401 = arith.extui %t394 : i16 to i32
        %t402 = arith.cmpi uge, %t401, %t400 : i32 loc(#loc136)
        scf.condition(%t402) %arg0 : i32
      } do {
        ^bb0(%t403: i32):
        %t404 = arith.constant 1 : i32 loc(#loc137)
        %t405 = arith.addi %t403, %t404 : i32 loc(#loc138)
        scf.yield %t405 : i32
      }
      %t406 = cal.get(%t38: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %t407 = arith.index_cast %t393 : i32 to index
      %t408 = arith.constant 1 : i32 loc(#loc140)
      %t409 = arith.subi %t396, %t408 : i32 loc(#loc141)
      %t410 = arith.index_cast %t409 : i32 to index
      %t411 = memref.load %t406[%t407, %t410] : memref<4x256xi32> loc(#loc139)
      cal.set(%t14: !cal.state_ref<i32>, %t411: i32)
      %t412 = cal.get(%t34: !cal.state_ref<memref<4x256xi32>>) : memref<4x256xi32>
      %t413 = cal.get(%t9: !cal.state_ref<i8>) : i8
      %t414 = arith.extui %t413 : i8 to i32
      %t415 = arith.index_cast %t414 : i32 to index
      %t416 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t417 = arith.index_cast %t416 : i32 to index
      %t418 = memref.load %t412[%t415, %t417] : memref<4x256xi32> loc(#loc173)
      cal.set(%t7: !cal.state_ref<i32>, %t418: i32)
      %t419 = cal.get(%t7: !cal.state_ref<i32>) : i32
      cal.set(%t5: !cal.state_ref<i32>, %t419: i32)
      %t420 = cal.get(%t12: !cal.state_ref<i32>) : i32
      %t421 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t422 = arith.constant 4 : i32 loc(#loc174)
      %t423 = arith.shrsi %t421, %t422 : i32 loc(#loc175)
      %t424 = arith.addi %t420, %t423 : i32 loc(#loc176)
      %t425 = arith.constant 1 : i32 loc(#loc177)
      %t426 = arith.addi %t424, %t425 : i32 loc(#loc176)
      cal.set(%t12: !cal.state_ref<i32>, %t426: i32)
    } loc(#loc170)
    cal.action "AC.done" priority=9 {
      cal.predicate {
        %t427 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t428 = arith.constant 0 : i32 loc(#loc179)
        %t429 = arith.cmpi eq, %t427, %t428 : i32 loc(#loc180)
        cal.predicate_result %t429 : i1
      }
      %t430 = arith.constant 0 : i32
      %t431 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t432 = arith.constant 15 : i32 loc(#loc181)
      %t433 = arith.andi %t431, %t432 : i32 loc(#loc182)
      cal.set(%t7: !cal.state_ref<i32>, %t433: i32)
      %t434 = cal.get(%t7: !cal.state_ref<i32>) : i32
      cal.set(%t5: !cal.state_ref<i32>, %t434: i32)
      %t435 = cal.get(%t2: !cal.state_ref<i16>) : i16
      %t436 = arith.constant 15 : i32 loc(#loc183)
      %t437 = cal.get(%t7: !cal.state_ref<i32>) : i32
      %t438 = arith.subi %t436, %t437 : i32 loc(#loc183)
      %t439 = arith.constant 1 : i32 loc(#loc184)
      %t440 = arith.addi %t438, %t439 : i32 loc(#loc185)
      %t441 = arith.extui %t435 : i16 to i32
      %t442 = arith.shrsi %t441, %t440 : i32 loc(#loc186)
      %t443 = arith.constant 1 : i32 loc(#loc187)
      %t444 = cal.get(%t5: !cal.state_ref<i32>) : i32
      %t445 = arith.constant 1 : i32 loc(#loc188)
      %t446 = arith.subi %t444, %t445 : i32 loc(#loc189)
      %t447 = arith.shli %t443, %t446 : i32 loc(#loc190)
      %t448 = arith.cmpi slt, %t442, %t447 : i32 loc(#loc191)
      %t449 = scf.if %t448 -> i32 {
        %t450 = arith.constant 1 : i32 loc(#loc192)
        %t451 = arith.constant 0 : i32 loc(#loc193)
        %t452 = arith.subi %t451, %t450 : i32 loc(#loc193)
        %t453 = cal.get(%t5: !cal.state_ref<i32>) : i32
        %t454 = arith.shli %t452, %t453 : i32 loc(#loc194)
        %t455 = arith.addi %t442, %t454 : i32 loc(#loc195)
        %t456 = arith.constant 1 : i32 loc(#loc196)
        %t457 = arith.addi %t455, %t456 : i32 loc(#loc195)
        scf.yield %t457 : i32
      } else {
        scf.yield %t442 : i32
      }
      %t458 = cal.get(%t12: !cal.state_ref<i32>) : i32
      %t459 = arith.index_cast %t458 : i32 to index
      %t460 = cal.get(%t49: !cal.state_ref<memref<64xi24>>) : memref<64xi24>
      %t461 = arith.trunci %t449 : i32 to i24
      memref.store %t461, %t460[%t459] : memref<64xi24>
    } loc(#loc178)
    cal.action "EOB" priority=10 {
      cal.predicate {
        %t462 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t463 = arith.constant 0 : i32 loc(#loc198)
        %t464 = arith.cmpi eq, %t462, %t463 : i32 loc(#loc199)
        %t465 = cal.get(%t14: !cal.state_ref<i32>) : i32
        %t466 = arith.constant 0 : i32 loc(#loc200)
        %t467 = arith.cmpi eq, %t465, %t466 : i32 loc(#loc201)
        %t468 = cal.get(%t12: !cal.state_ref<i32>) : i32
        %t469 = arith.constant 63 : i32 loc(#loc202)
        %t470 = arith.cmpi eq, %t468, %t469 : i32 loc(#loc203)
        %t471 = scf.if %t467 -> i1 {
          %t472 = arith.constant 1 : i1
          scf.yield %t472 : i1
        } else {
          scf.yield %t470 : i1
        }
        %t473 = scf.if %t464 -> i1 {
          scf.yield %t471 : i1
        } else {
          %t474 = arith.constant 0 : i1
          scf.yield %t474 : i1
        }
        cal.predicate_result %t473 : i1
      }
      %t475 = arith.constant 0 : i32
      %t476 = cal.get(%t41: !cal.state_ref<i32>) : i32
      %t477 = arith.constant 1 : i32 loc(#loc204)
      %t478 = arith.addi %t476, %t477 : i32 loc(#loc205)
      cal.set(%t41: !cal.state_ref<i32>, %t478: i32)
      %t479 = cal.get(%t41: !cal.state_ref<i32>) : i32
      %t480 = cal.get(%t45: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      %t481 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t482 = arith.index_cast %t481 : i32 to index
      %t483 = memref.load %t480[%t482] : memref<3xi32> loc(#loc206)
      %t484 = arith.cmpi eq, %t479, %t483 : i32 loc(#loc207)
      %t485 = scf.if %t484 -> i1 {
        %t486 = arith.constant 0 : i32 loc(#loc208)
        cal.set(%t41: !cal.state_ref<i32>, %t486: i32)
        %t487 = cal.get(%t43: !cal.state_ref<i32>) : i32
        %t488 = arith.constant 1 : i32 loc(#loc209)
        %t489 = arith.addi %t487, %t488 : i32 loc(#loc210)
        cal.set(%t43: !cal.state_ref<i32>, %t489: i32)
        %t490 = cal.get(%t43: !cal.state_ref<i32>) : i32
        %t491 = arith.constant 3 : i32 loc(#loc211)
        %t492 = arith.cmpi eq, %t490, %t491 : i32 loc(#loc212)
        %t493 = scf.if %t492 -> i1 {
          %t494 = arith.constant 0 : i32 loc(#loc213)
          cal.set(%t43: !cal.state_ref<i32>, %t494: i32)
          %t495 = arith.constant 1 : i1
          scf.yield %t495 : i1
        } else {
          %t496 = arith.constant 0 : i1
          scf.yield %t496 : i1
        }
        %t497 = arith.constant 1 : i1
        scf.yield %t497 : i1
      } else {
        %t498 = arith.constant 0 : i1
        scf.yield %t498 : i1
      }
      %t499 = cal.get(%t28: !cal.state_ref<memref<3xi8>>) : memref<3xi8>
      %t500 = cal.get(%t43: !cal.state_ref<i32>) : i32
      %t501 = arith.index_cast %t500 : i32 to index
      %t502 = memref.load %t499[%t501] : memref<3xi8> loc(#loc214)
      cal.set(%t9: !cal.state_ref<i8>, %t502: i8)
      %t503 = arith.constant 0 : i32 loc(#loc215)
      cal.set(%t5: !cal.state_ref<i32>, %t503: i32)
      %t504 = arith.constant 0 : i32 loc(#loc216)
      cal.set(%t7: !cal.state_ref<i32>, %t504: i32)
      %t505 = cal.get(%t12: !cal.state_ref<i32>) : i32
      %t506 = arith.constant 63 : i32 loc(#loc217)
      %t507 = arith.cmpi eq, %t505, %t506 : i32 loc(#loc218)
      %t508 = cal.get(%t14: !cal.state_ref<i32>) : i32
      %t509 = arith.constant 0 : i32 loc(#loc219)
      %t510 = arith.cmpi ne, %t508, %t509 : i32 loc(#loc220)
      %t511 = scf.if %t507 -> i1 {
        scf.yield %t510 : i1
      } else {
        %t512 = arith.constant 0 : i1
        scf.yield %t512 : i1
      }
      %t513 = scf.if %t511 -> (i32) {
        %t514 = cal.get(%t14: !cal.state_ref<i32>) : i32
        %t515 = arith.constant 15 : i32 loc(#loc221)
        %t516 = arith.andi %t514, %t515 : i32 loc(#loc222)
        cal.set(%t7: !cal.state_ref<i32>, %t516: i32)
        %t517 = cal.get(%t7: !cal.state_ref<i32>) : i32
        cal.set(%t5: !cal.state_ref<i32>, %t517: i32)
        %t518 = cal.get(%t2: !cal.state_ref<i16>) : i16
        %t519 = arith.constant 15 : i32 loc(#loc223)
        %t520 = cal.get(%t7: !cal.state_ref<i32>) : i32
        %t521 = arith.subi %t519, %t520 : i32 loc(#loc223)
        %t522 = arith.constant 1 : i32 loc(#loc224)
        %t523 = arith.addi %t521, %t522 : i32 loc(#loc225)
        %t524 = arith.extui %t518 : i16 to i32
        %t525 = arith.shrsi %t524, %t523 : i32 loc(#loc226)
        %t526 = arith.constant 1 : i32 loc(#loc227)
        %t527 = cal.get(%t5: !cal.state_ref<i32>) : i32
        %t528 = arith.constant 1 : i32 loc(#loc228)
        %t529 = arith.subi %t527, %t528 : i32 loc(#loc229)
        %t530 = arith.shli %t526, %t529 : i32 loc(#loc230)
        %t531 = arith.cmpi slt, %t525, %t530 : i32 loc(#loc231)
        %t532 = scf.if %t531 -> i32 {
          %t533 = arith.constant 1 : i32 loc(#loc232)
          %t534 = arith.constant 0 : i32 loc(#loc233)
          %t535 = arith.subi %t534, %t533 : i32 loc(#loc233)
          %t536 = cal.get(%t5: !cal.state_ref<i32>) : i32
          %t537 = arith.shli %t535, %t536 : i32 loc(#loc234)
          %t538 = arith.addi %t525, %t537 : i32 loc(#loc235)
          %t539 = arith.constant 1 : i32 loc(#loc236)
          %t540 = arith.addi %t538, %t539 : i32 loc(#loc235)
          scf.yield %t540 : i32
        } else {
          scf.yield %t525 : i32
        }
        %t541 = cal.get(%t12: !cal.state_ref<i32>) : i32
        %t542 = arith.index_cast %t541 : i32 to index
        %t543 = cal.get(%t49: !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        %t544 = arith.trunci %t532 : i32 to i24
        memref.store %t544, %t543[%t542] : memref<64xi24>
        %t545 = arith.constant 0 : i32 loc(#loc237)
        cal.set(%t5: !cal.state_ref<i32>, %t545: i32)
        scf.yield %t532 : i32
      } else {
        scf.yield %t475 : i32
      }
      %t546 = cal.get(%t16: !cal.state_ref<i32>) : i32
      %t547 = arith.constant 1 : i32 loc(#loc238)
      %t548 = arith.addi %t546, %t547 : i32 loc(#loc239)
      cal.set(%t16: !cal.state_ref<i32>, %t548: i32)
      %t549 = cal.get(%t25: !cal.state_ref<i64>) : i64
      %t550 = arith.constant 64 : i32 loc(#loc240)
      %t551 = arith.extsi %t550 : i32 to i64
      %t552 = arith.addi %t549, %t551 : i64 loc(#loc241)
      cal.set(%t25: !cal.state_ref<i64>, %t552: i64)
      %t553 = arith.constant 64 : i32 loc(#loc242)
      %t554 = arith.index_cast %t553 : i32 to index
      %t555 = arith.constant 0 : index
      %t556 = arith.constant 1 : index
      scf.for %t557 = %t555 to %t554 step %t556 {
        %t558 = cal.get(%t49: !cal.state_ref<memref<64xi24>>) : memref<64xi24>
        %t559 = memref.load %t558[%t557] : memref<64xi24>
        fifo.push(%Block: !fifo.input_port<i24>, %t559: i24)
        scf.yield
      }
    } loc(#loc197)
    cal.action "EOI" priority=12 {
      cal.predicate {
        %t560 = cal.get(%t16: !cal.state_ref<i32>) : i32
        %t561 = cal.get(%t18: !cal.state_ref<i32>) : i32
        %t562 = arith.cmpi eq, %t560, %t561 : i32 loc(#loc244)
        cal.predicate_result %t562 : i1
      }
      %t563 = arith.constant 0 : i32 loc(#loc245)
      cal.set(%t16: !cal.state_ref<i32>, %t563: i32)
      %t564 = arith.constant 0 : i32 loc(#loc246)
      cal.set(%t20: !cal.state_ref<i32>, %t564: i32)
      %t565 = arith.constant 0 : i32 loc(#loc247)
      cal.set(%t18: !cal.state_ref<i32>, %t565: i32)
      %t566 = arith.constant 0 : i32 loc(#loc248)
      cal.set(%t0: !cal.state_ref<i32>, %t566: i32)
      %t567 = arith.constant 0 : i32 loc(#loc249)
      %t568 = arith.trunci %t567 : i32 to i16
      cal.set(%t2: !cal.state_ref<i16>, %t568: i16)
      %t569 = arith.constant 0 : i32 loc(#loc250)
      cal.set(%t5: !cal.state_ref<i32>, %t569: i32)
      %t570 = arith.constant 0 : i32 loc(#loc251)
      cal.set(%t7: !cal.state_ref<i32>, %t570: i32)
      %t571 = cal.get(%t48: !cal.state_ref<memref<3xi32>>) : memref<3xi32>
      %t572 = arith.constant 0 : i32 loc(#loc252)
      %t573 = arith.constant 0 : index
      memref.store %t572, %t571[%t573] : memref<3xi32>
      %t574 = arith.constant 0 : i32 loc(#loc253)
      %t575 = arith.constant 1 : index
      memref.store %t574, %t571[%t575] : memref<3xi32>
      %t576 = arith.constant 0 : i32 loc(#loc254)
      %t577 = arith.constant 2 : index
      memref.store %t576, %t571[%t577] : memref<3xi32>
    } loc(#loc243)
  } loc(#loc255)
  cal.actor @jpeg_decoder_parallel__Splitter420()
    in_names ["YCbCr"]
    out_names ["Y", "Cb", "Cr"]
    ports_in(%YCbCr: !fifo.output_port<i24>)
    ports_out(%Y: !fifo.input_port<i24>, %Cb: !fifo.input_port<i24>, %Cr: !fifo.input_port<i24>)
  {
    %t0 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t1 = arith.constant 0 : i32 loc(#loc256)
    %t2 = arith.extsi %t1 : i32 to i64
    cal.set(%t0: !cal.state_ref<i64>, %t2: i64)
    %t3 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t4 = arith.constant 0 : i32 loc(#loc257)
    %t5 = arith.extsi %t4 : i32 to i64
    cal.set(%t3: !cal.state_ref<i64>, %t5: i64)
    cal.fsm {
      cal.state @Y0 {
        cal.transition action("Y") -> @Y1
      } { initial }
      cal.state @Cb {
        cal.transition action("Cb") -> @Cr
      }
      cal.state @Cr {
        cal.transition action("Cr") -> @Y0
      }
      cal.state @Y1 {
        cal.transition action("Y") -> @Y2
      }
      cal.state @Y2 {
        cal.transition action("Y") -> @Y3
      }
      cal.state @Y3 {
        cal.transition action("Y") -> @Cb
      }
    }
    cal.action "Y" priority=2 {
      %t6 = memref.alloca() : memref<64xi24>
      %t7 = arith.constant 64 : index
      %t8 = arith.constant 0 : index
      %t9 = arith.constant 1 : index
      scf.for %t10 = %t8 to %t7 step %t9 {
        %t11 = fifo.pop(%YCbCr: !fifo.output_port<i24> ) : i24
        memref.store %t11, %t6[%t10] : memref<64xi24>
        scf.yield
      }
      %t12 = cal.get(%t3: !cal.state_ref<i64>) : i64
      %t13 = arith.constant 64 : i32 loc(#loc259)
      %t14 = arith.extsi %t13 : i32 to i64
      %t15 = arith.addi %t12, %t14 : i64 loc(#loc260)
      cal.set(%t3: !cal.state_ref<i64>, %t15: i64)
      %t16 = arith.constant 64 : i32 loc(#loc261)
      %t17 = arith.index_cast %t16 : i32 to index
      %t18 = arith.constant 0 : index
      %t19 = arith.constant 1 : index
      scf.for %t20 = %t18 to %t17 step %t19 {
        %t21 = memref.load %t6[%t20] : memref<64xi24>
        fifo.push(%Y: !fifo.input_port<i24>, %t21: i24)
        scf.yield
      }
    } loc(#loc258)
    cal.action "Cb" priority=2 {
      %t22 = memref.alloca() : memref<64xi24>
      %t23 = arith.constant 64 : index
      %t24 = arith.constant 0 : index
      %t25 = arith.constant 1 : index
      scf.for %t26 = %t24 to %t23 step %t25 {
        %t27 = fifo.pop(%YCbCr: !fifo.output_port<i24> ) : i24
        memref.store %t27, %t22[%t26] : memref<64xi24>
        scf.yield
      }
      %t28 = cal.get(%t3: !cal.state_ref<i64>) : i64
      %t29 = arith.constant 64 : i32 loc(#loc263)
      %t30 = arith.extsi %t29 : i32 to i64
      %t31 = arith.addi %t28, %t30 : i64 loc(#loc264)
      cal.set(%t3: !cal.state_ref<i64>, %t31: i64)
      %t32 = arith.constant 64 : i32 loc(#loc265)
      %t33 = arith.index_cast %t32 : i32 to index
      %t34 = arith.constant 0 : index
      %t35 = arith.constant 1 : index
      scf.for %t36 = %t34 to %t33 step %t35 {
        %t37 = memref.load %t22[%t36] : memref<64xi24>
        fifo.push(%Cb: !fifo.input_port<i24>, %t37: i24)
        scf.yield
      }
    } loc(#loc262)
    cal.action "Cr" priority=2 {
      %t38 = memref.alloca() : memref<64xi24>
      %t39 = arith.constant 64 : index
      %t40 = arith.constant 0 : index
      %t41 = arith.constant 1 : index
      scf.for %t42 = %t40 to %t39 step %t41 {
        %t43 = fifo.pop(%YCbCr: !fifo.output_port<i24> ) : i24
        memref.store %t43, %t38[%t42] : memref<64xi24>
        scf.yield
      }
      %t44 = cal.get(%t3: !cal.state_ref<i64>) : i64
      %t45 = arith.constant 64 : i32 loc(#loc267)
      %t46 = arith.extsi %t45 : i32 to i64
      %t47 = arith.addi %t44, %t46 : i64 loc(#loc268)
      cal.set(%t3: !cal.state_ref<i64>, %t47: i64)
      %t48 = arith.constant 64 : i32 loc(#loc269)
      %t49 = arith.index_cast %t48 : i32 to index
      %t50 = arith.constant 0 : index
      %t51 = arith.constant 1 : index
      scf.for %t52 = %t50 to %t49 step %t51 {
        %t53 = memref.load %t38[%t52] : memref<64xi24>
        fifo.push(%Cr: !fifo.input_port<i24>, %t53: i24)
        scf.yield
      }
    } loc(#loc266)
  } loc(#loc270)
  cal.actor @jpeg_decoder_parallel__Merger420()
    in_names ["Y", "Cb", "Cr"]
    out_names ["YCbCr"]
    ports_in(%Y: !fifo.output_port<i8>, %Cb: !fifo.output_port<i8>, %Cr: !fifo.output_port<i8>)
    ports_out(%YCbCr: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t1 = arith.constant 0 : i32 loc(#loc271)
    %t2 = arith.extsi %t1 : i32 to i64
    cal.set(%t0: !cal.state_ref<i64>, %t2: i64)
    %t3 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t4 = arith.constant 0 : i32 loc(#loc272)
    %t5 = arith.extsi %t4 : i32 to i64
    cal.set(%t3: !cal.state_ref<i64>, %t5: i64)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 0 : i32 loc(#loc273)
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    cal.fsm {
      cal.state @Y0 {
        cal.transition action("Y") -> @Y1
      } { initial }
      cal.state @Cb {
        cal.transition action("Cb") -> @Cr
      }
      cal.state @Cr {
        cal.transition action("Cr") -> @Y0
      }
      cal.state @Y1 {
        cal.transition action("Y") -> @Y2
      }
      cal.state @Y2 {
        cal.transition action("Y") -> @Y3
      }
      cal.state @Y3 {
        cal.transition action("Y") -> @Cb
      }
    }
    cal.action "Y" priority=2 {
      %t8 = memref.alloca() : memref<64xi8>
      %t9 = arith.constant 64 : index
      %t10 = arith.constant 0 : index
      %t11 = arith.constant 1 : index
      scf.for %t12 = %t10 to %t9 step %t11 {
        %t13 = fifo.pop(%Y: !fifo.output_port<i8> ) : i8
        memref.store %t13, %t8[%t12] : memref<64xi8>
        scf.yield
      }
      %t14 = cal.get(%t0: !cal.state_ref<i64>) : i64
      %t15 = arith.constant 64 : i32 loc(#loc275)
      %t16 = arith.extsi %t15 : i32 to i64
      %t17 = arith.addi %t14, %t16 : i64 loc(#loc276)
      cal.set(%t0: !cal.state_ref<i64>, %t17: i64)
      %t18 = arith.constant 64 : i32 loc(#loc277)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = arith.constant 0 : index
      %t21 = arith.constant 1 : index
      scf.for %t22 = %t20 to %t19 step %t21 {
        %t23 = memref.load %t8[%t22] : memref<64xi8>
        fifo.push(%YCbCr: !fifo.input_port<i8>, %t23: i8)
        scf.yield
      }
    } loc(#loc274)
    cal.action "Cb" priority=2 {
      %t24 = memref.alloca() : memref<64xi8>
      %t25 = arith.constant 64 : index
      %t26 = arith.constant 0 : index
      %t27 = arith.constant 1 : index
      scf.for %t28 = %t26 to %t25 step %t27 {
        %t29 = fifo.pop(%Cb: !fifo.output_port<i8> ) : i8
        memref.store %t29, %t24[%t28] : memref<64xi8>
        scf.yield
      }
      %t30 = arith.constant 64 : i32 loc(#loc279)
      %t31 = arith.index_cast %t30 : i32 to index
      %t32 = arith.constant 0 : index
      %t33 = arith.constant 1 : index
      scf.for %t34 = %t32 to %t31 step %t33 {
        %t35 = memref.load %t24[%t34] : memref<64xi8>
        fifo.push(%YCbCr: !fifo.input_port<i8>, %t35: i8)
        scf.yield
      }
    } loc(#loc278)
    cal.action "Cr" priority=2 {
      %t36 = memref.alloca() : memref<64xi8>
      %t37 = arith.constant 64 : index
      %t38 = arith.constant 0 : index
      %t39 = arith.constant 1 : index
      scf.for %t40 = %t38 to %t37 step %t39 {
        %t41 = fifo.pop(%Cr: !fifo.output_port<i8> ) : i8
        memref.store %t41, %t36[%t40] : memref<64xi8>
        scf.yield
      }
      %t42 = arith.constant 64 : i32 loc(#loc281)
      %t43 = arith.index_cast %t42 : i32 to index
      %t44 = arith.constant 0 : index
      %t45 = arith.constant 1 : index
      scf.for %t46 = %t44 to %t43 step %t45 {
        %t47 = memref.load %t36[%t46] : memref<64xi8>
        fifo.push(%YCbCr: !fifo.input_port<i8>, %t47: i8)
        scf.yield
      }
    } loc(#loc280)
  } loc(#loc282)
  cal.actor @jpeg_decoder_parallel_parser__ParseJPEG()
    in_names ["Byte"]
    out_names ["Data", "QT", "HT", "SOI"]
    ports_in(%Byte: !fifo.output_port<i8>)
    ports_out(%Data: !fifo.input_port<i8>, %QT: !fifo.input_port<i8>, %HT: !fifo.input_port<i8>, %SOI: !fifo.input_port<i16>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 1 : i32 loc(#loc283)
    %t4 = arith.constant 0 : i32 loc(#loc284)
    %t5 = arith.subi %t4, %t3 : i32 loc(#loc284)
    cal.set(%t2: !cal.state_ref<i32>, %t5: i32)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 0 : i32 loc(#loc285)
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    %t8 = cal.create_state_var<i8> : !cal.state_ref<i8>
    %t9 = arith.constant 0 : i32 loc(#loc286)
    %t10 = arith.trunci %t9 : i32 to i8
    cal.set(%t8: !cal.state_ref<i8>, %t10: i8)
    cal.fsm {
      cal.state @wait_SOI {
        cal.transition action("SOI") -> @wait_marker
      } { initial }
      cal.state @handle_marker {
        cal.transition action("APPn") -> @skip_bytes
        cal.transition action("COMM") -> @skip_bytes
        cal.transition action("DQT") -> @wait_DQT
        cal.transition action("SOF0") -> @wait_marker
        cal.transition action("DHT") -> @wait_DHT
        cal.transition action("SOS") -> @wait_scan_header
      }
      cal.state @is_stuffing {
        cal.transition action("stuffing") -> @wait_scan_data
        cal.transition action("EOI") -> @padding
      }
      cal.state @padding {
        cal.transition action("padding16") -> @wait_SOI
      }
      cal.state @skip_bytes {
        cal.transition action("skip") -> @skip_bytes
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_DHT {
        cal.transition action("send_DHT") -> @wait_DHT
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_DQT {
        cal.transition action("send_DQT") -> @wait_DQT
        cal.transition action("done") -> @wait_marker
      }
      cal.state @wait_marker {
        cal.transition action("receive_marker") -> @handle_marker
      }
      cal.state @wait_scan_data {
        cal.transition action("scan_data") -> @wait_scan_data
        cal.transition action("receive_FF") -> @is_stuffing
      }
      cal.state @wait_scan_header {
        cal.transition action("skip") -> @wait_scan_header
        cal.transition action("done") -> @wait_scan_data
      }
    }
    cal.action "SOI" priority=16 {
      %t11 = memref.alloca() : memref<2xi8>
      %t12 = arith.constant 2 : index
      %t13 = arith.constant 0 : index
      %t14 = arith.constant 1 : index
      scf.for %t15 = %t13 to %t12 step %t14 {
        %t16 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
        memref.store %t16, %t11[%t15] : memref<2xi8>
        scf.yield
      }
      %t17 = arith.constant 2 : i32 loc(#loc288)
      cal.set(%t0: !cal.state_ref<i32>, %t17: i32)
      %t18 = arith.constant 1 : i32 loc(#loc289)
      %t19 = arith.constant 0 : i32 loc(#loc290)
      %t20 = arith.subi %t19, %t18 : i32 loc(#loc290)
      cal.set(%t2: !cal.state_ref<i32>, %t20: i32)
      %t21 = arith.constant 0 : i32 loc(#loc291)
      cal.set(%t6: !cal.state_ref<i32>, %t21: i32)
      %t22 = arith.constant 0 : i32 loc(#loc292)
      %t23 = arith.trunci %t22 : i32 to i8
      cal.set(%t8: !cal.state_ref<i8>, %t23: i8)
      %t24 = arith.constant 0 : i32 loc(#loc293)
      %t25 = arith.index_cast %t24 : i32 to index
      %t26 = memref.load %t11[%t25] : memref<2xi8> loc(#loc294)
      %t27 = arith.constant 255 : i32 loc(#loc295)
      %t28 = arith.extui %t26 : i8 to i32
      %t29 = arith.cmpi eq, %t28, %t27 : i32 loc(#loc294)
      %t30 = arith.constant 1 : i32 loc(#loc296)
      %t31 = arith.index_cast %t30 : i32 to index
      %t32 = memref.load %t11[%t31] : memref<2xi8> loc(#loc297)
      %t33 = arith.constant 216 : i32 loc(#loc298)
      %t34 = arith.extui %t32 : i8 to i32
      %t35 = arith.cmpi eq, %t34, %t33 : i32 loc(#loc297)
      %t36 = scf.if %t29 -> i1 {
        scf.yield %t35 : i1
      } else {
        %t37 = arith.constant 0 : i1
        scf.yield %t37 : i1
      }
      %t38 = scf.if %t36 -> i1 {
        %t39 = arith.constant 1 : i1
        scf.yield %t39 : i1
      } else {
        %t40 = arith.constant 0 : i1
        scf.yield %t40 : i1
      }
    } loc(#loc287)
    cal.action "receive_marker" priority=16 {
      %t41 = memref.alloca() : memref<4xi8>
      %t42 = arith.constant 4 : index
      %t43 = arith.constant 0 : index
      %t44 = arith.constant 1 : index
      scf.for %t45 = %t43 to %t42 step %t44 {
        %t46 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
        memref.store %t46, %t41[%t45] : memref<4xi8>
        scf.yield
      }
      %t47 = arith.constant 3 : i32 loc(#loc300)
      %t48 = arith.index_cast %t47 : i32 to index
      %t49 = memref.load %t41[%t48] : memref<4xi8> loc(#loc301)
      %t50 = arith.constant 2 : i32 loc(#loc302)
      %t51 = arith.index_cast %t50 : i32 to index
      %t52 = memref.load %t41[%t51] : memref<4xi8> loc(#loc303)
      %t53 = arith.constant 8 : i32 loc(#loc304)
      %t54 = arith.extui %t52 : i8 to i32
      %t55 = arith.shli %t54, %t53 : i32 loc(#loc305)
      %t56 = arith.extui %t49 : i8 to i32
      %t57 = arith.addi %t56, %t55 : i32 loc(#loc301)
      %t58 = arith.constant 2 : i32 loc(#loc306)
      %t59 = arith.subi %t57, %t58 : i32 loc(#loc301)
      cal.set(%t2: !cal.state_ref<i32>, %t59: i32)
      %t60 = arith.constant 1 : i32 loc(#loc307)
      %t61 = arith.index_cast %t60 : i32 to index
      %t62 = memref.load %t41[%t61] : memref<4xi8> loc(#loc308)
      cal.set(%t8: !cal.state_ref<i8>, %t62: i8)
      %t63 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t64 = arith.constant 4 : i32 loc(#loc309)
      %t65 = arith.addi %t63, %t64 : i32 loc(#loc310)
      cal.set(%t0: !cal.state_ref<i32>, %t65: i32)
    } loc(#loc299)
    cal.action "skip" priority=16 {
      cal.predicate {
        %t66 = cal.get(%t2: !cal.state_ref<i32>) : i32
        %t67 = arith.constant 0 : i32 loc(#loc312)
        %t68 = arith.cmpi ne, %t66, %t67 : i32 loc(#loc313)
        cal.predicate_result %t68 : i1
      }
      %t69 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t70 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t71 = arith.constant 1 : i32 loc(#loc314)
      %t72 = arith.subi %t70, %t71 : i32 loc(#loc315)
      cal.set(%t2: !cal.state_ref<i32>, %t72: i32)
      %t73 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t74 = arith.constant 1 : i32 loc(#loc316)
      %t75 = arith.addi %t73, %t74 : i32 loc(#loc317)
      cal.set(%t0: !cal.state_ref<i32>, %t75: i32)
    } loc(#loc311)
    cal.action "done" priority=16 {
      cal.predicate {
        %t76 = cal.get(%t2: !cal.state_ref<i32>) : i32
        %t77 = arith.constant 0 : i32 loc(#loc319)
        %t78 = arith.cmpi eq, %t76, %t77 : i32 loc(#loc320)
        cal.predicate_result %t78 : i1
      }
      %t79 = arith.constant 1 : i32 loc(#loc321)
      %t80 = arith.constant 0 : i32 loc(#loc322)
      %t81 = arith.subi %t80, %t79 : i32 loc(#loc322)
      cal.set(%t2: !cal.state_ref<i32>, %t81: i32)
    } loc(#loc318)
    cal.action "APPn" priority=16 {
      cal.predicate {
        %t82 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t83 = arith.constant 224 : i32 loc(#loc324)
        %t84 = arith.extui %t82 : i8 to i32
        %t85 = arith.cmpi uge, %t84, %t83 : i32 loc(#loc325)
        %t86 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t87 = arith.constant 239 : i32 loc(#loc326)
        %t88 = arith.extui %t86 : i8 to i32
        %t89 = arith.cmpi ule, %t88, %t87 : i32 loc(#loc327)
        %t90 = scf.if %t85 -> i1 {
          scf.yield %t89 : i1
        } else {
          %t91 = arith.constant 0 : i1
          scf.yield %t91 : i1
        }
        cal.predicate_result %t90 : i1
      }
    } loc(#loc323)
    cal.action "COMM" priority=16 {
      cal.predicate {
        %t92 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t93 = arith.constant 254 : i32 loc(#loc329)
        %t94 = arith.extui %t92 : i8 to i32
        %t95 = arith.cmpi eq, %t94, %t93 : i32 loc(#loc330)
        cal.predicate_result %t95 : i1
      }
    } loc(#loc328)
    cal.action "DQT" priority=16 {
      cal.predicate {
        %t96 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t97 = arith.constant 219 : i32 loc(#loc332)
        %t98 = arith.extui %t96 : i8 to i32
        %t99 = arith.cmpi eq, %t98, %t97 : i32 loc(#loc333)
        cal.predicate_result %t99 : i1
      }
      %t100 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t101 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t102 = arith.addi %t100, %t101 : i32 loc(#loc334)
      cal.set(%t0: !cal.state_ref<i32>, %t102: i32)
    } loc(#loc331)
    cal.action "send_DQT" priority=16 {
      cal.predicate {
        %t103 = cal.get(%t2: !cal.state_ref<i32>) : i32
        %t104 = arith.constant 0 : i32 loc(#loc336)
        %t105 = arith.cmpi ne, %t103, %t104 : i32 loc(#loc337)
        cal.predicate_result %t105 : i1
      }
      %t106 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t107 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t108 = arith.constant 1 : i32 loc(#loc338)
      %t109 = arith.subi %t107, %t108 : i32 loc(#loc339)
      cal.set(%t2: !cal.state_ref<i32>, %t109: i32)
      fifo.push(%QT: !fifo.input_port<i8>, %t106: i8)
    } loc(#loc335)
    cal.action "SOF0" priority=16 {
      cal.predicate {
        %t110 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t111 = arith.constant 192 : i32 loc(#loc341)
        %t112 = arith.extui %t110 : i8 to i32
        %t113 = arith.cmpi eq, %t112, %t111 : i32 loc(#loc342)
        cal.predicate_result %t113 : i1
      }
      %t114 = arith.constant 0 : i32
      %t115 = arith.constant 0 : i32
      %t116 = memref.alloca() : memref<15xi8>
      %t117 = arith.constant 15 : index
      %t118 = arith.constant 0 : index
      %t119 = arith.constant 1 : index
      scf.for %t120 = %t118 to %t117 step %t119 {
        %t121 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
        memref.store %t121, %t116[%t120] : memref<15xi8>
        scf.yield
      }
      %t122 = arith.constant 1 : i32 loc(#loc343)
      %t123 = arith.index_cast %t122 : i32 to index
      %t124 = memref.load %t116[%t123] : memref<15xi8> loc(#loc344)
      %t125 = arith.constant 8 : i32 loc(#loc345)
      %t126 = arith.extui %t124 : i8 to i32
      %t127 = arith.constant 0 : i32
      %t128 = arith.shli %t126, %t125 : i32 loc(#loc0)
      %t129 = arith.constant 2 : i32 loc(#loc346)
      %t130 = arith.index_cast %t129 : i32 to index
      %t131 = memref.load %t116[%t130] : memref<15xi8> loc(#loc347)
      %t132 = arith.extui %t131 : i8 to i32
      %t133 = arith.addi %t128, %t132 : i32 loc(#loc348)
      %t134 = arith.constant 3 : i32 loc(#loc349)
      %t135 = arith.index_cast %t134 : i32 to index
      %t136 = memref.load %t116[%t135] : memref<15xi8> loc(#loc350)
      %t137 = arith.constant 8 : i32 loc(#loc351)
      %t138 = arith.extui %t136 : i8 to i32
      %t139 = arith.constant 0 : i32
      %t140 = arith.shli %t138, %t137 : i32 loc(#loc0)
      %t141 = arith.constant 4 : i32 loc(#loc352)
      %t142 = arith.index_cast %t141 : i32 to index
      %t143 = memref.load %t116[%t142] : memref<15xi8> loc(#loc353)
      %t144 = arith.extui %t143 : i8 to i32
      %t145 = arith.addi %t140, %t144 : i32 loc(#loc354)
      %t146 = arith.constant 4 : i32 loc(#loc355)
      %t147 = arith.shrsi %t145, %t146 : i32 loc(#loc356)
      %t148 = arith.trunci %t147 : i32 to i16
      fifo.push(%SOI: !fifo.input_port<i16>, %t148: i16)
      %t149 = arith.constant 4 : i32 loc(#loc357)
      %t150 = arith.shrsi %t133, %t149 : i32 loc(#loc358)
      %t151 = arith.trunci %t150 : i32 to i16
      fifo.push(%SOI: !fifo.input_port<i16>, %t151: i16)
    } loc(#loc340)
    cal.action "DHT" priority=16 {
      cal.predicate {
        %t152 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t153 = arith.constant 196 : i32 loc(#loc360)
        %t154 = arith.extui %t152 : i8 to i32
        %t155 = arith.cmpi eq, %t154, %t153 : i32 loc(#loc361)
        cal.predicate_result %t155 : i1
      }
    } loc(#loc359)
    cal.action "send_DHT" priority=16 {
      cal.predicate {
        %t156 = cal.get(%t2: !cal.state_ref<i32>) : i32
        %t157 = arith.constant 0 : i32 loc(#loc363)
        %t158 = arith.cmpi ne, %t156, %t157 : i32 loc(#loc364)
        cal.predicate_result %t158 : i1
      }
      %t159 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t160 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t161 = arith.constant 1 : i32 loc(#loc365)
      %t162 = arith.subi %t160, %t161 : i32 loc(#loc366)
      cal.set(%t2: !cal.state_ref<i32>, %t162: i32)
      %t163 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t164 = arith.constant 1 : i32 loc(#loc367)
      %t165 = arith.addi %t163, %t164 : i32 loc(#loc368)
      cal.set(%t0: !cal.state_ref<i32>, %t165: i32)
      fifo.push(%HT: !fifo.input_port<i8>, %t159: i8)
    } loc(#loc362)
    cal.action "SOS" priority=16 {
      cal.predicate {
        %t166 = cal.get(%t8: !cal.state_ref<i8>) : i8
        %t167 = arith.constant 218 : i32 loc(#loc370)
        %t168 = arith.extui %t166 : i8 to i32
        %t169 = arith.cmpi eq, %t168, %t167 : i32 loc(#loc371)
        cal.predicate_result %t169 : i1
      }
    } loc(#loc369)
    cal.action "scan_data" priority=16 {
      cal.predicate {
        %t171 = arith.constant 0 : index
        %t170 = fifo.peek(%Byte: !fifo.output_port<i8>, %t171: index) : i8
        %t172 = arith.constant 255 : i32 loc(#loc373)
        %t173 = arith.extui %t170 : i8 to i32
        %t174 = arith.cmpi ne, %t173, %t172 : i32 loc(#loc374)
        cal.predicate_result %t174 : i1
      }
      %t175 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t176 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t177 = arith.constant 1 : i32 loc(#loc375)
      %t178 = arith.addi %t176, %t177 : i32 loc(#loc376)
      cal.set(%t0: !cal.state_ref<i32>, %t178: i32)
      %t179 = cal.get(%t6: !cal.state_ref<i32>) : i32
      %t180 = arith.constant 1 : i32 loc(#loc377)
      %t181 = arith.addi %t179, %t180 : i32 loc(#loc378)
      cal.set(%t6: !cal.state_ref<i32>, %t181: i32)
      fifo.push(%Data: !fifo.input_port<i8>, %t175: i8)
    } loc(#loc372)
    cal.action "receive_FF" priority=16 {
      cal.predicate {
        %t183 = arith.constant 0 : index
        %t182 = fifo.peek(%Byte: !fifo.output_port<i8>, %t183: index) : i8
        %t184 = arith.constant 255 : i32 loc(#loc380)
        %t185 = arith.extui %t182 : i8 to i32
        %t186 = arith.cmpi eq, %t185, %t184 : i32 loc(#loc381)
        cal.predicate_result %t186 : i1
      }
      %t187 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t188 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t189 = arith.constant 1 : i32 loc(#loc382)
      %t190 = arith.addi %t188, %t189 : i32 loc(#loc383)
      cal.set(%t0: !cal.state_ref<i32>, %t190: i32)
    } loc(#loc379)
    cal.action "stuffing" priority=16 {
      cal.predicate {
        %t192 = arith.constant 0 : index
        %t191 = fifo.peek(%Byte: !fifo.output_port<i8>, %t192: index) : i8
        %t193 = arith.constant 0 : i32 loc(#loc385)
        %t194 = arith.extui %t191 : i8 to i32
        %t195 = arith.cmpi eq, %t194, %t193 : i32 loc(#loc386)
        cal.predicate_result %t195 : i1
      }
      %t196 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t197 = cal.get(%t6: !cal.state_ref<i32>) : i32
      %t198 = arith.constant 1 : i32 loc(#loc387)
      %t199 = arith.addi %t197, %t198 : i32 loc(#loc388)
      cal.set(%t6: !cal.state_ref<i32>, %t199: i32)
      %t200 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t201 = arith.constant 1 : i32 loc(#loc389)
      %t202 = arith.addi %t200, %t201 : i32 loc(#loc390)
      cal.set(%t0: !cal.state_ref<i32>, %t202: i32)
      %t203 = arith.constant 255 : i32 loc(#loc391)
      %t204 = arith.trunci %t203 : i32 to i8
      fifo.push(%Data: !fifo.input_port<i8>, %t204: i8)
    } loc(#loc384)
    cal.action "EOI" priority=16 {
      cal.predicate {
        %t206 = arith.constant 0 : index
        %t205 = fifo.peek(%Byte: !fifo.output_port<i8>, %t206: index) : i8
        %t207 = arith.constant 217 : i32 loc(#loc393)
        %t208 = arith.extui %t205 : i8 to i32
        %t209 = arith.cmpi eq, %t208, %t207 : i32 loc(#loc394)
        cal.predicate_result %t209 : i1
      }
      %t210 = fifo.pop(%Byte: !fifo.output_port<i8> ) : i8
      %t211 = cal.get(%t0: !cal.state_ref<i32>) : i32
      %t212 = arith.constant 1 : i32 loc(#loc395)
      %t213 = arith.addi %t211, %t212 : i32 loc(#loc396)
      cal.set(%t0: !cal.state_ref<i32>, %t213: i32)
    } loc(#loc392)
    cal.action "padding16" priority=16 {
      %t214 = arith.constant 0 : i32 loc(#loc398)
      %t215 = arith.trunci %t214 : i32 to i8
      fifo.push(%Data: !fifo.input_port<i8>, %t215: i8)
      %t216 = arith.constant 0 : i32 loc(#loc399)
      %t217 = arith.trunci %t216 : i32 to i8
      fifo.push(%Data: !fifo.input_port<i8>, %t217: i8)
    } loc(#loc397)
  } loc(#loc400)
  cal.actor @jpeg_decoder_parallel_parser__SplitQT()
    in_names ["QT"]
    out_names ["QT_Y", "QT_UV_1", "QT_UV_2"]
    ports_in(%QT: !fifo.output_port<i8>)
    ports_out(%QT_Y: !fifo.input_port<i8>, %QT_UV_1: !fifo.input_port<i8>, %QT_UV_2: !fifo.input_port<i8>)
  {
    cal.fsm {
      cal.state @wait_dest_ID {
        cal.transition action("Luminance") -> @wait_Luminance
        cal.transition action("Chrominance") -> @wait_Chrominance
      } { initial }
      cal.state @wait_Chrominance {
        cal.transition action("receive_Chrominance") -> @wait_dest_ID
      }
      cal.state @wait_Luminance {
        cal.transition action("receive_Luminance") -> @wait_dest_ID
      }
    }
    cal.action "Luminance" priority=3 {
      cal.predicate {
        %t1 = arith.constant 0 : index
        %t0 = fifo.peek(%QT: !fifo.output_port<i8>, %t1: index) : i8
        %t2 = arith.constant 0 : i32 loc(#loc402)
        %t3 = arith.extui %t0 : i8 to i32
        %t4 = arith.cmpi eq, %t3, %t2 : i32 loc(#loc403)
        cal.predicate_result %t4 : i1
      }
      %t5 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
    } loc(#loc401)
    cal.action "Chrominance" priority=3 {
      cal.predicate {
        %t7 = arith.constant 0 : index
        %t6 = fifo.peek(%QT: !fifo.output_port<i8>, %t7: index) : i8
        %t8 = arith.constant 1 : i32 loc(#loc405)
        %t9 = arith.extui %t6 : i8 to i32
        %t10 = arith.cmpi eq, %t9, %t8 : i32 loc(#loc406)
        cal.predicate_result %t10 : i1
      }
      %t11 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
    } loc(#loc404)
    cal.action "receive_Luminance" priority=3 {
      %t12 = memref.alloca() : memref<64xi8>
      %t13 = arith.constant 64 : index
      %t14 = arith.constant 0 : index
      %t15 = arith.constant 1 : index
      scf.for %t16 = %t14 to %t13 step %t15 {
        %t17 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
        memref.store %t17, %t12[%t16] : memref<64xi8>
        scf.yield
      }
      %t18 = arith.constant 64 : i32 loc(#loc408)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = arith.constant 0 : index
      %t21 = arith.constant 1 : index
      scf.for %t22 = %t20 to %t19 step %t21 {
        %t23 = memref.load %t12[%t22] : memref<64xi8>
        fifo.push(%QT_Y: !fifo.input_port<i8>, %t23: i8)
        scf.yield
      }
    } loc(#loc407)
    cal.action "receive_Chrominance" priority=3 {
      %t24 = memref.alloca() : memref<64xi8>
      %t25 = arith.constant 64 : index
      %t26 = arith.constant 0 : index
      %t27 = arith.constant 1 : index
      scf.for %t28 = %t26 to %t25 step %t27 {
        %t29 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
        memref.store %t29, %t24[%t28] : memref<64xi8>
        scf.yield
      }
      %t30 = arith.constant 64 : i32 loc(#loc410)
      %t31 = arith.index_cast %t30 : i32 to index
      %t32 = arith.constant 0 : index
      %t33 = arith.constant 1 : index
      scf.for %t34 = %t32 to %t31 step %t33 {
        %t35 = memref.load %t24[%t34] : memref<64xi8>
        fifo.push(%QT_UV_1: !fifo.input_port<i8>, %t35: i8)
        scf.yield
      }
      %t36 = arith.constant 64 : i32 loc(#loc411)
      %t37 = arith.index_cast %t36 : i32 to index
      %t38 = arith.constant 0 : index
      %t39 = arith.constant 1 : index
      scf.for %t40 = %t38 to %t37 step %t39 {
        %t41 = memref.load %t24[%t40] : memref<64xi8>
        fifo.push(%QT_UV_2: !fifo.input_port<i8>, %t41: i8)
        scf.yield
      }
    } loc(#loc409)
  } loc(#loc412)
  cal.actor @jpeg_io__Source__v__frames_300(%frames: i32)
    out_names ["Out"]
    ports_out(%Out: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t1 = arith.constant 0 : i32 loc(#loc413)
    cal.set(%t0: !cal.state_ref<i32>, %t1: i32)
    %t2 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t3 = arith.constant 0 : i32 loc(#loc414)
    cal.set(%t2: !cal.state_ref<i32>, %t3: i32)
    %t4 = cal.create_state_var<memref<3867xi8>> : !cal.state_ref<memref<3867xi8>>
    %t5 = cal.get(%t4: !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
    %t6 = memref.get_global @__cmr_3 : memref<3867xi8>
    memref.copy %t6, %t5 : memref<3867xi8> to memref<3867xi8>
    cal.action "$untagged0" priority=2 {
      cal.predicate {
        %t7 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t8 = arith.constant 3840 : i32 loc(#loc416)
        %t9 = arith.cmpi ult, %t7, %t8 : i32 loc(#loc417)
        cal.predicate_result %t9 : i1
      }
      %t10 = memref.alloca() : memref<64xi8>
      %t11 = arith.constant 0 : i32 loc(#loc418)
      %t12 = arith.constant 63 : i32 loc(#loc419)
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.index_cast %t12 : i32 to index
      %t15 = arith.constant 1 : index
      %t16 = arith.addi %t14, %t15 : index
      scf.for %t17 = %t13 to %t16 step %t15 {
        %t18 = cal.get(%t4: !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %t19 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t20 = arith.index_cast %t19 : i32 to index
        %t21 = memref.load %t18[%t20] : memref<3867xi8> loc(#loc420)
        memref.store %t21, %t10[%t17] : memref<64xi8>
        %t22 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t23 = arith.constant 1 : i32 loc(#loc421)
        %t24 = arith.addi %t22, %t23 : i32 loc(#loc422)
        cal.set(%t0: !cal.state_ref<i32>, %t24: i32)
        scf.yield
      }
      %t25 = arith.constant 64 : i32 loc(#loc423)
      %t26 = arith.index_cast %t25 : i32 to index
      %t27 = arith.constant 0 : index
      %t28 = arith.constant 1 : index
      scf.for %t29 = %t27 to %t26 step %t28 {
        %t30 = memref.load %t10[%t29] : memref<64xi8>
        fifo.push(%Out: !fifo.input_port<i8>, %t30: i8)
        scf.yield
      }
    } loc(#loc415)
    cal.action "$untagged1" priority=2 {
      cal.predicate {
        %t31 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t32 = arith.constant 3840 : i32 loc(#loc425)
        %t33 = arith.cmpi uge, %t31, %t32 : i32 loc(#loc426)
        %t34 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t35 = arith.constant 3867 : i32 loc(#loc427)
        %t36 = arith.cmpi ult, %t34, %t35 : i32 loc(#loc428)
        %t37 = scf.if %t33 -> i1 {
          scf.yield %t36 : i1
        } else {
          %t38 = arith.constant 0 : i1
          scf.yield %t38 : i1
        }
        cal.predicate_result %t37 : i1
      }
      %t39 = memref.alloca() : memref<27xi8>
      %t40 = arith.constant 0 : i32 loc(#loc429)
      %t41 = arith.constant 26 : i32 loc(#loc430)
      %t42 = arith.index_cast %t40 : i32 to index
      %t43 = arith.index_cast %t41 : i32 to index
      %t44 = arith.constant 1 : index
      %t45 = arith.addi %t43, %t44 : index
      scf.for %t46 = %t42 to %t45 step %t44 {
        %t47 = cal.get(%t4: !cal.state_ref<memref<3867xi8>>) : memref<3867xi8>
        %t48 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t49 = arith.index_cast %t48 : i32 to index
        %t50 = memref.load %t47[%t49] : memref<3867xi8> loc(#loc431)
        memref.store %t50, %t39[%t46] : memref<27xi8>
        %t51 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t52 = arith.constant 1 : i32 loc(#loc432)
        %t53 = arith.addi %t51, %t52 : i32 loc(#loc433)
        cal.set(%t0: !cal.state_ref<i32>, %t53: i32)
        scf.yield
      }
      %t54 = arith.constant 27 : i32 loc(#loc434)
      %t55 = arith.index_cast %t54 : i32 to index
      %t56 = arith.constant 0 : index
      %t57 = arith.constant 1 : index
      scf.for %t58 = %t56 to %t55 step %t57 {
        %t59 = memref.load %t39[%t58] : memref<27xi8>
        fifo.push(%Out: !fifo.input_port<i8>, %t59: i8)
        scf.yield
      }
    } loc(#loc424)
    cal.action "$untagged2" priority=2 {
      cal.predicate {
        %t60 = cal.get(%t0: !cal.state_ref<i32>) : i32
        %t61 = arith.constant 3867 : i32 loc(#loc436)
        %t62 = arith.cmpi eq, %t60, %t61 : i32 loc(#loc437)
        %t63 = cal.get(%t2: !cal.state_ref<i32>) : i32
        %t64 = arith.cmpi ult, %t63, %frames : i32 loc(#loc438)
        %t65 = scf.if %t62 -> i1 {
          scf.yield %t64 : i1
        } else {
          %t66 = arith.constant 0 : i1
          scf.yield %t66 : i1
        }
        cal.predicate_result %t65 : i1
      }
      %t67 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t68 = arith.constant 1 : i32 loc(#loc439)
      %t69 = arith.addi %t67, %t68 : i32 loc(#loc440)
      cal.set(%t2: !cal.state_ref<i32>, %t69: i32)
      %t70 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t71 = arith.constant 1000 : i32 loc(#loc441)
      %t72 = arith.remui %t70, %t71 : i32 loc(#loc442)
      %t73 = arith.constant 0 : i32 loc(#loc443)
      %t74 = arith.cmpi eq, %t72, %t73 : i32 loc(#loc442)
      %t75 = scf.if %t74 -> i1 {
        %t76 = cal.get(%t2: !cal.state_ref<i32>) : i32
        fifo.print("Finished sending frame %u\n\00", %t76) : (i32)
        %t77 = arith.constant 1 : i1
        scf.yield %t77 : i1
      } else {
        %t78 = arith.constant 0 : i1
        scf.yield %t78 : i1
      }
      %t79 = cal.get(%t2: !cal.state_ref<i32>) : i32
      %t80 = arith.cmpi ult, %t79, %frames : i32 loc(#loc444)
      %t81 = scf.if %t80 -> i1 {
        %t82 = arith.constant 0 : i32 loc(#loc445)
        cal.set(%t0: !cal.state_ref<i32>, %t82: i32)
        %t83 = arith.constant 1 : i1
        scf.yield %t83 : i1
      } else {
        %t84 = arith.constant 0 : i1
        scf.yield %t84 : i1
      }
    } loc(#loc435)
  } loc(#loc446)
  cal.network @jpeg_decoder_parallel_idct__IDCT2D(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i8>)
  {
    %scale = cal.instantiate @jpeg_decoder_parallel_idct__Scale__v__index_0 (%index : i32) instance("scale") {cal.instance_name = "scale", cal.class_name = "@jpeg_decoder_parallel_idct__Scale__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Scale__v__index_0>
    %row = cal.instantiate @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0 (%index : i32) instance("row") {cal.instance_name = "row", cal.class_name = "@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0>
    %transpose = cal.instantiate @jpeg_decoder_parallel_idct__Transpose__v__index_0 (%index : i32) instance("transpose") {cal.instance_name = "transpose", cal.class_name = "@jpeg_decoder_parallel_idct__Transpose__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0>
    %column = cal.instantiate @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0 (%index : i32) instance("column") {cal.instance_name = "column", cal.class_name = "@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0>
    %retranspose = cal.instantiate @jpeg_decoder_parallel_idct__Transpose__v__index_0 (%index : i32) instance("retranspose") {cal.instance_name = "retranspose", cal.class_name = "@jpeg_decoder_parallel_idct__Transpose__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0>
    %shift = cal.instantiate @jpeg_decoder_parallel_idct__Rightshift__v__index_0 (%index : i32) instance("shift") {cal.instance_name = "shift", cal.class_name = "@jpeg_decoder_parallel_idct__Rightshift__v__index_0"} : !cal.instance<@jpeg_decoder_parallel_idct__Rightshift__v__index_0>
    cal.connect %IN : !fifo.output_port<i13> "out" -> %scale : !cal.instance<@jpeg_decoder_parallel_idct__Scale__v__index_0> "IN" capacity(65536)
    cal.connect %scale : !cal.instance<@jpeg_decoder_parallel_idct__Scale__v__index_0> "OUT" -> %row : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0> "IN" capacity(65536)
    cal.connect %row : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0> "OUT" -> %transpose : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0> "IN" capacity(65536)
    cal.connect %transpose : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0> "OUT" -> %column : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0> "IN" capacity(65536)
    cal.connect %column : !cal.instance<@jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0> "OUT" -> %retranspose : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0> "IN" capacity(65536)
    cal.connect %retranspose : !cal.instance<@jpeg_decoder_parallel_idct__Transpose__v__index_0> "OUT" -> %shift : !cal.instance<@jpeg_decoder_parallel_idct__Rightshift__v__index_0> "IN" capacity(65536)
    cal.connect %shift : !cal.instance<@jpeg_decoder_parallel_idct__Rightshift__v__index_0> "OUT" -> %OUT : !fifo.input_port<i8> "in" capacity(65536)
  }
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_4(%mb: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in(%SOI: !fifo.output_port<i16>, %QT: !fifo.output_port<i8>, %Block: !fifo.output_port<i24>)
    ports_out(%Out: !fifo.input_port<i13>)
  {
    %t0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %t1 = cal.get(%t0: !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %t2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %t2, %t1 : memref<64xi6> to memref<64xi6>
    %t3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %t4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t5 = arith.constant 0 : i32
    cal.set(%t4: !cal.state_ref<i32>, %t5: i32)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 0 : i32
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } { initial }
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3 {
      %t8 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t9 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t10 = arith.extui %t8 : i16 to i32
      %t12 = arith.extsi %mb : i32 to i64
      %t13 = arith.extui %t10 : i32 to i64
      %t11 = arith.muli %t12, %t13 : i64 loc(#loc448)
      %t14 = arith.extui %t9 : i16 to i64
      %t15 = arith.muli %t11, %t14 : i64 loc(#loc448)
      %t16 = arith.trunci %t15 : i64 to i32
      cal.set(%t4: !cal.state_ref<i32>, %t16: i32)
      %t17 = arith.constant 0 : i32 loc(#loc449)
      cal.set(%t6: !cal.state_ref<i32>, %t17: i32)
    } loc(#loc447)
    cal.action "receive_QT" priority=3 {
      %t18 = memref.alloca() : memref<64xi8>
      %t19 = arith.constant 64 : index
      %t20 = arith.constant 0 : index
      %t21 = arith.constant 1 : index
      scf.for %t22 = %t20 to %t19 step %t21 {
        %t23 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
        memref.store %t23, %t18[%t22] : memref<64xi8>
        scf.yield
      }
      %t24 = cal.get(%t3: !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      %t25 = arith.constant 0 : i32 loc(#loc451)
      %t26 = arith.constant 63 : i32 loc(#loc452)
      %t27 = arith.index_cast %t25 : i32 to index
      %t28 = arith.index_cast %t26 : i32 to index
      %t29 = arith.constant 1 : index
      %t30 = arith.addi %t28, %t29 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t27 to %t30 step %t31 {
        %t33 = arith.index_cast %t32 : index to i32
        %t34 = arith.index_cast %t33 : i32 to index
        %t35 = memref.load %t18[%t34] : memref<64xi8> loc(#loc453)
        %t36 = arith.subi %t32, %t27 : index
        memref.store %t35, %t24[%t36] : memref<64xi8>
        scf.yield
      }
    } loc(#loc450)
    cal.action "receive_block" priority=2 {
      %t37 = memref.alloca() : memref<64xi32>
      %t38 = memref.alloca() : memref<64xi24>
      %t39 = arith.constant 64 : index
      %t40 = arith.constant 0 : index
      %t41 = arith.constant 1 : index
      scf.for %t42 = %t40 to %t39 step %t41 {
        %t43 = fifo.pop(%Block: !fifo.output_port<i24> ) : i24
        memref.store %t43, %t38[%t42] : memref<64xi24>
        scf.yield
      }
      %t44 = arith.constant 0 : i32 loc(#loc455)
      %t45 = arith.constant 63 : i32 loc(#loc456)
      %t46 = arith.index_cast %t44 : i32 to index
      %t47 = arith.index_cast %t45 : i32 to index
      %t48 = arith.constant 1 : index
      %t49 = arith.addi %t47, %t48 : index
      %t50 = arith.constant 1 : index
      scf.for %t51 = %t46 to %t49 step %t50 {
        %t52 = arith.index_cast %t51 : index to i32
        %t53 = arith.index_cast %t52 : i32 to index
        %t54 = memref.load %t38[%t53] : memref<64xi24> loc(#loc457)
        %t55 = cal.get(%t3: !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %t56 = arith.index_cast %t52 : i32 to index
        %t57 = memref.load %t55[%t56] : memref<64xi8> loc(#loc458)
        %t58 = arith.extsi %t57 : i8 to i24
        %t60 = arith.extsi %t54 : i24 to i48
        %t61 = arith.extsi %t58 : i24 to i48
        %t59 = arith.muli %t60, %t61 : i48 loc(#loc457)
        %t62 = arith.trunci %t59 : i48 to i32
        %t63 = arith.subi %t51, %t46 : index
        memref.store %t62, %t37[%t63] : memref<64xi32>
        scf.yield
      }
      %t64 = cal.get(%t6: !cal.state_ref<i32>) : i32
      %t65 = arith.constant 1 : i32 loc(#loc459)
      %t66 = arith.addi %t64, %t65 : i32 loc(#loc460)
      cal.set(%t6: !cal.state_ref<i32>, %t66: i32)
      %t67 = arith.constant 0 : i32 loc(#loc461)
      %t68 = arith.constant 63 : i32 loc(#loc462)
      %t69 = arith.index_cast %t67 : i32 to index
      %t70 = arith.index_cast %t68 : i32 to index
      %t71 = arith.constant 1 : index
      %t72 = arith.addi %t70, %t71 : index
      %t73 = arith.constant 1 : index
      scf.for %t74 = %t69 to %t72 step %t73 {
        %t75 = arith.index_cast %t74 : index to i32
        %t76 = cal.get(%t0: !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %t77 = arith.index_cast %t75 : i32 to index
        %t78 = memref.load %t76[%t77] : memref<64xi6> loc(#loc463)
        %t79 = arith.extui %t78 : i6 to i32
        %t80 = arith.index_cast %t79 : i32 to index
        %t81 = memref.load %t37[%t80] : memref<64xi32> loc(#loc464)
        %t82 = arith.trunci %t81 : i32 to i13
        fifo.push(%Out: !fifo.input_port<i13>, %t82: i13)
        scf.yield
      }
    } loc(#loc454)
    cal.action "eoi" priority=3 {
      cal.predicate {
        %t83 = cal.get(%t6: !cal.state_ref<i32>) : i32
        %t84 = cal.get(%t4: !cal.state_ref<i32>) : i32
        %t85 = arith.cmpi eq, %t83, %t84 : i32 loc(#loc466)
        cal.predicate_result %t85 : i1
      }
    } loc(#loc465)
  } loc(#loc467)
  cal.actor @jpeg_decoder_parallel_dequant__Dequant__v__mb_1(%mb: i32)
    in_names ["SOI", "QT", "Block"]
    out_names ["Out"]
    ports_in(%SOI: !fifo.output_port<i16>, %QT: !fifo.output_port<i8>, %Block: !fifo.output_port<i24>)
    ports_out(%Out: !fifo.input_port<i13>)
  {
    %t0 = cal.create_state_var<memref<64xi6>> : !cal.state_ref<memref<64xi6>>
    %t1 = cal.get(%t0: !cal.state_ref<memref<64xi6>>) : memref<64xi6>
    %t2 = memref.get_global @__cmr_4 : memref<64xi6>
    memref.copy %t2, %t1 : memref<64xi6> to memref<64xi6>
    %t3 = cal.create_state_var<memref<64xi8>> : !cal.state_ref<memref<64xi8>>
    %t4 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t5 = arith.constant 0 : i32
    cal.set(%t4: !cal.state_ref<i32>, %t5: i32)
    %t6 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t7 = arith.constant 0 : i32
    cal.set(%t6: !cal.state_ref<i32>, %t7: i32)
    cal.fsm {
      cal.state @s0 {
        cal.transition action("get_SOI") -> @s1
      } { initial }
      cal.state @s1 {
        cal.transition action("receive_QT") -> @s2
      }
      cal.state @s2 {
        cal.transition action("receive_block") -> @s2
        cal.transition action("eoi") -> @s0
      }
    }
    cal.action "get_SOI" priority=3 {
      %t8 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t9 = fifo.pop(%SOI: !fifo.output_port<i16> ) : i16
      %t10 = arith.extui %t8 : i16 to i32
      %t12 = arith.extsi %mb : i32 to i64
      %t13 = arith.extui %t10 : i32 to i64
      %t11 = arith.muli %t12, %t13 : i64 loc(#loc448)
      %t14 = arith.extui %t9 : i16 to i64
      %t15 = arith.muli %t11, %t14 : i64 loc(#loc448)
      %t16 = arith.trunci %t15 : i64 to i32
      cal.set(%t4: !cal.state_ref<i32>, %t16: i32)
      %t17 = arith.constant 0 : i32 loc(#loc449)
      cal.set(%t6: !cal.state_ref<i32>, %t17: i32)
    } loc(#loc447)
    cal.action "receive_QT" priority=3 {
      %t18 = memref.alloca() : memref<64xi8>
      %t19 = arith.constant 64 : index
      %t20 = arith.constant 0 : index
      %t21 = arith.constant 1 : index
      scf.for %t22 = %t20 to %t19 step %t21 {
        %t23 = fifo.pop(%QT: !fifo.output_port<i8> ) : i8
        memref.store %t23, %t18[%t22] : memref<64xi8>
        scf.yield
      }
      %t24 = cal.get(%t3: !cal.state_ref<memref<64xi8>>) : memref<64xi8>
      %t25 = arith.constant 0 : i32 loc(#loc451)
      %t26 = arith.constant 63 : i32 loc(#loc452)
      %t27 = arith.index_cast %t25 : i32 to index
      %t28 = arith.index_cast %t26 : i32 to index
      %t29 = arith.constant 1 : index
      %t30 = arith.addi %t28, %t29 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t27 to %t30 step %t31 {
        %t33 = arith.index_cast %t32 : index to i32
        %t34 = arith.index_cast %t33 : i32 to index
        %t35 = memref.load %t18[%t34] : memref<64xi8> loc(#loc453)
        %t36 = arith.subi %t32, %t27 : index
        memref.store %t35, %t24[%t36] : memref<64xi8>
        scf.yield
      }
    } loc(#loc450)
    cal.action "receive_block" priority=2 {
      %t37 = memref.alloca() : memref<64xi32>
      %t38 = memref.alloca() : memref<64xi24>
      %t39 = arith.constant 64 : index
      %t40 = arith.constant 0 : index
      %t41 = arith.constant 1 : index
      scf.for %t42 = %t40 to %t39 step %t41 {
        %t43 = fifo.pop(%Block: !fifo.output_port<i24> ) : i24
        memref.store %t43, %t38[%t42] : memref<64xi24>
        scf.yield
      }
      %t44 = arith.constant 0 : i32 loc(#loc455)
      %t45 = arith.constant 63 : i32 loc(#loc456)
      %t46 = arith.index_cast %t44 : i32 to index
      %t47 = arith.index_cast %t45 : i32 to index
      %t48 = arith.constant 1 : index
      %t49 = arith.addi %t47, %t48 : index
      %t50 = arith.constant 1 : index
      scf.for %t51 = %t46 to %t49 step %t50 {
        %t52 = arith.index_cast %t51 : index to i32
        %t53 = arith.index_cast %t52 : i32 to index
        %t54 = memref.load %t38[%t53] : memref<64xi24> loc(#loc457)
        %t55 = cal.get(%t3: !cal.state_ref<memref<64xi8>>) : memref<64xi8>
        %t56 = arith.index_cast %t52 : i32 to index
        %t57 = memref.load %t55[%t56] : memref<64xi8> loc(#loc458)
        %t58 = arith.extsi %t57 : i8 to i24
        %t60 = arith.extsi %t54 : i24 to i48
        %t61 = arith.extsi %t58 : i24 to i48
        %t59 = arith.muli %t60, %t61 : i48 loc(#loc457)
        %t62 = arith.trunci %t59 : i48 to i32
        %t63 = arith.subi %t51, %t46 : index
        memref.store %t62, %t37[%t63] : memref<64xi32>
        scf.yield
      }
      %t64 = cal.get(%t6: !cal.state_ref<i32>) : i32
      %t65 = arith.constant 1 : i32 loc(#loc459)
      %t66 = arith.addi %t64, %t65 : i32 loc(#loc460)
      cal.set(%t6: !cal.state_ref<i32>, %t66: i32)
      %t67 = arith.constant 0 : i32 loc(#loc461)
      %t68 = arith.constant 63 : i32 loc(#loc462)
      %t69 = arith.index_cast %t67 : i32 to index
      %t70 = arith.index_cast %t68 : i32 to index
      %t71 = arith.constant 1 : index
      %t72 = arith.addi %t70, %t71 : index
      %t73 = arith.constant 1 : index
      scf.for %t74 = %t69 to %t72 step %t73 {
        %t75 = arith.index_cast %t74 : index to i32
        %t76 = cal.get(%t0: !cal.state_ref<memref<64xi6>>) : memref<64xi6>
        %t77 = arith.index_cast %t75 : i32 to index
        %t78 = memref.load %t76[%t77] : memref<64xi6> loc(#loc463)
        %t79 = arith.extui %t78 : i6 to i32
        %t80 = arith.index_cast %t79 : i32 to index
        %t81 = memref.load %t37[%t80] : memref<64xi32> loc(#loc464)
        %t82 = arith.trunci %t81 : i32 to i13
        fifo.push(%Out: !fifo.input_port<i13>, %t82: i13)
        scf.yield
      }
    } loc(#loc454)
    cal.action "eoi" priority=3 {
      cal.predicate {
        %t83 = cal.get(%t6: !cal.state_ref<i32>) : i32
        %t84 = cal.get(%t4: !cal.state_ref<i32>) : i32
        %t85 = arith.cmpi eq, %t83, %t84 : i32 loc(#loc466)
        cal.predicate_result %t85 : i1
      }
    } loc(#loc465)
  } loc(#loc467)
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_dyn(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t2 = arith.constant 1024 : i32 loc(#loc468)
    cal.set(%t1: !cal.state_ref<i32>, %t2: i32)
    %t3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t4 = arith.constant 1138 : i32 loc(#loc469)
    cal.set(%t3: !cal.state_ref<i32>, %t4: i32)
    %t5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t6 = arith.constant 1730 : i32 loc(#loc470)
    cal.set(%t5: !cal.state_ref<i32>, %t6: i32)
    %t7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t8 = arith.constant 1609 : i32 loc(#loc471)
    cal.set(%t7: !cal.state_ref<i32>, %t8: i32)
    %t9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t10 = arith.constant 1264 : i32 loc(#loc472)
    cal.set(%t9: !cal.state_ref<i32>, %t10: i32)
    %t11 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t12 = arith.constant 1922 : i32 loc(#loc473)
    cal.set(%t11: !cal.state_ref<i32>, %t12: i32)
    %t13 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t14 = arith.constant 1788 : i32 loc(#loc474)
    cal.set(%t13: !cal.state_ref<i32>, %t14: i32)
    %t15 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t16 = arith.constant 2923 : i32 loc(#loc475)
    cal.set(%t15: !cal.state_ref<i32>, %t16: i32)
    %t17 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t18 = arith.constant 2718 : i32 loc(#loc476)
    cal.set(%t17: !cal.state_ref<i32>, %t18: i32)
    %t19 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t20 = arith.constant 2528 : i32 loc(#loc477)
    cal.set(%t19: !cal.state_ref<i32>, %t20: i32)
    %t21 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %t22 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %t23 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %t23, %t22 : memref<64xi16> to memref<64xi16>
    %t24 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t25 = arith.constant 0 : i32 loc(#loc478)
    %t26 = arith.extsi %t25 : i32 to i64
    cal.set(%t24: !cal.state_ref<i64>, %t26: i64)
    cal.action "scale" priority=0 {
      %t27 = memref.alloca() : memref<64xi32>
      %t28 = memref.alloca() : memref<64xi13>
      %t29 = arith.constant 64 : index
      %t30 = arith.constant 0 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t30 to %t29 step %t31 {
        %t33 = fifo.pop(%IN: !fifo.output_port<i13> ) : i13
        memref.store %t33, %t28[%t32] : memref<64xi13>
        scf.yield
      }
      %t34 = arith.constant 0 : i32 loc(#loc480)
      %t35 = arith.constant 63 : i32 loc(#loc481)
      %t36 = arith.index_cast %t34 : i32 to index
      %t37 = arith.index_cast %t35 : i32 to index
      %t38 = arith.constant 1 : index
      %t39 = arith.addi %t37, %t38 : index
      %t40 = arith.constant 1 : index
      scf.for %t41 = %t36 to %t39 step %t40 {
        %t42 = arith.index_cast %t41 : index to i32
        %t43 = arith.index_cast %t42 : i32 to index
        %t44 = memref.load %t28[%t43] : memref<64xi13> loc(#loc482)
        %t45 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %t46 = arith.index_cast %t42 : i32 to index
        %t47 = memref.load %t45[%t46] : memref<64xi16> loc(#loc483)
        %t48 = arith.extsi %t44 : i13 to i16
        %t50 = arith.extsi %t48 : i16 to i32
        %t51 = arith.extsi %t47 : i16 to i32
        %t49 = arith.muli %t50, %t51 : i32 loc(#loc482)
        %t52 = arith.subi %t41, %t36 : index
        memref.store %t49, %t27[%t52] : memref<64xi32>
        scf.yield
      }
      %t53 = arith.constant 0 : i32 loc(#loc484)
      %t54 = arith.index_cast %t53 : i32 to index
      %t55 = arith.constant 0 : i32 loc(#loc485)
      %t56 = arith.index_cast %t55 : i32 to index
      %t57 = memref.load %t27[%t56] : memref<64xi32> loc(#loc486)
      %t58 = arith.constant 4096 : i32 loc(#loc487)
      %t59 = arith.addi %t57, %t58 : i32 loc(#loc486)
      memref.store %t59, %t27[%t54] : memref<64xi32>
      %t60 = cal.get(%t24: !cal.state_ref<i64>) : i64
      %t61 = arith.constant 64 : i32 loc(#loc488)
      %t62 = arith.extsi %t61 : i32 to i64
      %t63 = arith.addi %t60, %t62 : i64 loc(#loc489)
      cal.set(%t24: !cal.state_ref<i64>, %t63: i64)
      %t64 = arith.constant 64 : i32 loc(#loc490)
      %t65 = arith.index_cast %t64 : i32 to index
      %t66 = arith.constant 0 : index
      %t67 = arith.constant 1 : index
      scf.for %t68 = %t66 to %t65 step %t67 {
        %t69 = memref.load %t27[%t68] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t69: i32)
        scf.yield
      }
    } loc(#loc479)
  } loc(#loc491)
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_dyn(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc492)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = arith.constant 0 : i32
      %t5 = arith.constant 0 : i32
      %t6 = arith.constant 0 : i32
      %t7 = arith.constant 0 : i32
      %t8 = arith.constant 0 : i32
      %t9 = arith.constant 0 : i32
      %t10 = memref.alloca() : memref<8xi32>
      %t11 = memref.alloca() : memref<8xi32>
      %t12 = memref.alloca() : memref<8xi32>
      %t13 = arith.constant 8 : index
      %t14 = arith.constant 0 : index
      %t15 = arith.constant 1 : index
      scf.for %t16 = %t14 to %t13 step %t15 {
        %t17 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t17, %t12[%t16] : memref<8xi32>
        scf.yield
      }
      memref.copy %t12, %t11 : memref<8xi32> to memref<8xi32>
      %t18 = arith.constant 1 : i32 loc(#loc494)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = memref.load %t11[%t19] : memref<8xi32> loc(#loc495)
      %t21 = arith.constant 7 : i32 loc(#loc496)
      %t22 = arith.index_cast %t21 : i32 to index
      %t23 = memref.load %t11[%t22] : memref<8xi32> loc(#loc497)
      %t24 = arith.addi %t20, %t23 : i32 loc(#loc495)
      %t25 = arith.constant 1 : i32 loc(#loc498)
      %t26 = arith.index_cast %t25 : i32 to index
      %t27 = memref.load %t11[%t26] : memref<8xi32> loc(#loc499)
      %t28 = arith.constant 7 : i32 loc(#loc500)
      %t29 = arith.index_cast %t28 : i32 to index
      %t30 = memref.load %t11[%t29] : memref<8xi32> loc(#loc501)
      %t31 = arith.subi %t27, %t30 : i32 loc(#loc499)
      %t32 = arith.constant 1 : i32 loc(#loc502)
      %t33 = arith.index_cast %t32 : i32 to index
      %t34 = arith.constant 3 : i32 loc(#loc503)
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = memref.load %t11[%t35] : memref<8xi32> loc(#loc504)
      %t37 = arith.addi %t24, %t36 : i32 loc(#loc505)
      memref.store %t37, %t11[%t33] : memref<8xi32>
      %t38 = arith.constant 3 : i32 loc(#loc506)
      %t39 = arith.index_cast %t38 : i32 to index
      %t40 = arith.constant 3 : i32 loc(#loc507)
      %t41 = arith.index_cast %t40 : i32 to index
      %t42 = memref.load %t11[%t41] : memref<8xi32> loc(#loc508)
      %t43 = arith.subi %t24, %t42 : i32 loc(#loc509)
      memref.store %t43, %t11[%t39] : memref<8xi32>
      %t44 = arith.constant 7 : i32 loc(#loc510)
      %t45 = arith.index_cast %t44 : i32 to index
      %t46 = arith.constant 5 : i32 loc(#loc511)
      %t47 = arith.index_cast %t46 : i32 to index
      %t48 = memref.load %t11[%t47] : memref<8xi32> loc(#loc512)
      %t49 = arith.addi %t31, %t48 : i32 loc(#loc513)
      memref.store %t49, %t11[%t45] : memref<8xi32>
      %t50 = arith.constant 5 : i32 loc(#loc514)
      %t51 = arith.index_cast %t50 : i32 to index
      %t52 = arith.constant 5 : i32 loc(#loc515)
      %t53 = arith.index_cast %t52 : i32 to index
      %t54 = memref.load %t11[%t53] : memref<8xi32> loc(#loc516)
      %t55 = arith.subi %t31, %t54 : i32 loc(#loc517)
      memref.store %t55, %t11[%t51] : memref<8xi32>
      %t56 = arith.constant 3 : i32 loc(#loc518)
      %t57 = arith.index_cast %t56 : i32 to index
      %t58 = memref.load %t11[%t57] : memref<8xi32> loc(#loc519)
      %t59 = arith.constant 0 : i32
      %t60 = arith.constant 3 : i32 loc(#loc520)
      %t61 = arith.constant 0 : i32
      %t62 = arith.shrsi %t58, %t60 : i32 loc(#loc1)
      %t63 = arith.constant 7 : i32 loc(#loc521)
      %t64 = arith.constant 0 : i32
      %t65 = arith.shrsi %t58, %t63 : i32 loc(#loc1)
      %t66 = arith.subi %t62, %t65 : i32 loc(#loc522)
      %t67 = arith.subi %t58, %t66 : i32 loc(#loc523)
      %t68 = arith.constant 3 : i32 loc(#loc524)
      %t69 = arith.index_cast %t68 : i32 to index
      %t70 = memref.load %t11[%t69] : memref<8xi32> loc(#loc525)
      %t71 = arith.constant 0 : i32
      %t72 = arith.constant 3 : i32 loc(#loc526)
      %t73 = arith.constant 0 : i32
      %t74 = arith.shrsi %t70, %t72 : i32 loc(#loc1)
      %t75 = arith.constant 7 : i32 loc(#loc527)
      %t76 = arith.constant 0 : i32
      %t77 = arith.shrsi %t70, %t75 : i32 loc(#loc1)
      %t78 = arith.subi %t74, %t77 : i32 loc(#loc528)
      %t79 = arith.constant 11 : i32 loc(#loc529)
      %t80 = arith.constant 0 : i32
      %t81 = arith.shrsi %t70, %t79 : i32 loc(#loc1)
      %t82 = arith.subi %t78, %t81 : i32 loc(#loc530)
      %t83 = arith.constant 1 : i32 loc(#loc531)
      %t84 = arith.constant 0 : i32
      %t85 = arith.shrsi %t82, %t83 : i32 loc(#loc1)
      %t86 = arith.addi %t78, %t85 : i32 loc(#loc532)
      %t87 = arith.constant 5 : i32 loc(#loc533)
      %t88 = arith.index_cast %t87 : i32 to index
      %t89 = memref.load %t11[%t88] : memref<8xi32> loc(#loc534)
      %t90 = arith.constant 0 : i32
      %t91 = arith.constant 3 : i32 loc(#loc520)
      %t92 = arith.constant 0 : i32
      %t93 = arith.shrsi %t89, %t91 : i32 loc(#loc1)
      %t94 = arith.constant 7 : i32 loc(#loc521)
      %t95 = arith.constant 0 : i32
      %t96 = arith.shrsi %t89, %t94 : i32 loc(#loc1)
      %t97 = arith.subi %t93, %t96 : i32 loc(#loc522)
      %t98 = arith.subi %t89, %t97 : i32 loc(#loc523)
      %t99 = arith.constant 5 : i32 loc(#loc535)
      %t100 = arith.index_cast %t99 : i32 to index
      %t101 = memref.load %t11[%t100] : memref<8xi32> loc(#loc536)
      %t102 = arith.constant 0 : i32
      %t103 = arith.constant 3 : i32 loc(#loc526)
      %t104 = arith.constant 0 : i32
      %t105 = arith.shrsi %t101, %t103 : i32 loc(#loc1)
      %t106 = arith.constant 7 : i32 loc(#loc527)
      %t107 = arith.constant 0 : i32
      %t108 = arith.shrsi %t101, %t106 : i32 loc(#loc1)
      %t109 = arith.subi %t105, %t108 : i32 loc(#loc528)
      %t110 = arith.constant 11 : i32 loc(#loc529)
      %t111 = arith.constant 0 : i32
      %t112 = arith.shrsi %t101, %t110 : i32 loc(#loc1)
      %t113 = arith.subi %t109, %t112 : i32 loc(#loc530)
      %t114 = arith.constant 1 : i32 loc(#loc531)
      %t115 = arith.constant 0 : i32
      %t116 = arith.shrsi %t113, %t114 : i32 loc(#loc1)
      %t117 = arith.addi %t109, %t116 : i32 loc(#loc532)
      %t118 = arith.constant 3 : i32 loc(#loc537)
      %t119 = arith.index_cast %t118 : i32 to index
      %t120 = arith.subi %t67, %t117 : i32 loc(#loc538)
      memref.store %t120, %t11[%t119] : memref<8xi32>
      %t121 = arith.constant 5 : i32 loc(#loc539)
      %t122 = arith.index_cast %t121 : i32 to index
      %t123 = arith.addi %t98, %t86 : i32 loc(#loc540)
      memref.store %t123, %t11[%t122] : memref<8xi32>
      %t124 = arith.constant 1 : i32 loc(#loc541)
      %t125 = arith.index_cast %t124 : i32 to index
      %t126 = memref.load %t11[%t125] : memref<8xi32> loc(#loc542)
      %t127 = arith.constant 0 : i32
      %t128 = arith.constant 9 : i32 loc(#loc543)
      %t129 = arith.constant 0 : i32
      %t130 = arith.shrsi %t126, %t128 : i32 loc(#loc1)
      %t131 = arith.subi %t130, %t126 : i32 loc(#loc544)
      %t132 = arith.constant 2 : i32 loc(#loc545)
      %t133 = arith.constant 0 : i32
      %t134 = arith.shrsi %t131, %t132 : i32 loc(#loc1)
      %t135 = arith.subi %t134, %t131 : i32 loc(#loc546)
      %t136 = arith.constant 1 : i32 loc(#loc547)
      %t137 = arith.index_cast %t136 : i32 to index
      %t138 = memref.load %t11[%t137] : memref<8xi32> loc(#loc548)
      %t139 = arith.constant 0 : i32
      %t140 = arith.constant 1 : i32 loc(#loc549)
      %t141 = arith.constant 0 : i32
      %t142 = arith.shrsi %t138, %t140 : i32 loc(#loc1)
      %t143 = arith.constant 7 : i32 loc(#loc550)
      %t144 = arith.index_cast %t143 : i32 to index
      %t145 = memref.load %t11[%t144] : memref<8xi32> loc(#loc551)
      %t146 = arith.constant 0 : i32
      %t147 = arith.constant 9 : i32 loc(#loc543)
      %t148 = arith.constant 0 : i32
      %t149 = arith.shrsi %t145, %t147 : i32 loc(#loc1)
      %t150 = arith.subi %t149, %t145 : i32 loc(#loc544)
      %t151 = arith.constant 2 : i32 loc(#loc545)
      %t152 = arith.constant 0 : i32
      %t153 = arith.shrsi %t150, %t151 : i32 loc(#loc1)
      %t154 = arith.subi %t153, %t150 : i32 loc(#loc546)
      %t155 = arith.constant 7 : i32 loc(#loc552)
      %t156 = arith.index_cast %t155 : i32 to index
      %t157 = memref.load %t11[%t156] : memref<8xi32> loc(#loc553)
      %t158 = arith.constant 0 : i32
      %t159 = arith.constant 1 : i32 loc(#loc549)
      %t160 = arith.constant 0 : i32
      %t161 = arith.shrsi %t157, %t159 : i32 loc(#loc1)
      %t162 = arith.constant 1 : i32 loc(#loc554)
      %t163 = arith.index_cast %t162 : i32 to index
      %t164 = arith.addi %t135, %t161 : i32 loc(#loc555)
      memref.store %t164, %t11[%t163] : memref<8xi32>
      %t165 = arith.constant 7 : i32 loc(#loc556)
      %t166 = arith.index_cast %t165 : i32 to index
      %t167 = arith.subi %t154, %t142 : i32 loc(#loc557)
      memref.store %t167, %t11[%t166] : memref<8xi32>
      %t168 = arith.constant 2 : i32 loc(#loc558)
      %t169 = arith.index_cast %t168 : i32 to index
      %t170 = memref.load %t11[%t169] : memref<8xi32> loc(#loc559)
      %t171 = arith.constant 0 : i32
      %t172 = arith.constant 5 : i32 loc(#loc560)
      %t173 = arith.constant 0 : i32
      %t174 = arith.shrsi %t170, %t172 : i32 loc(#loc1)
      %t175 = arith.addi %t170, %t174 : i32 loc(#loc561)
      %t176 = arith.constant 2 : i32 loc(#loc562)
      %t177 = arith.constant 0 : i32
      %t178 = arith.shrsi %t175, %t176 : i32 loc(#loc1)
      %t179 = arith.constant 4 : i32 loc(#loc563)
      %t180 = arith.constant 0 : i32
      %t181 = arith.shrsi %t170, %t179 : i32 loc(#loc1)
      %t182 = arith.addi %t178, %t181 : i32 loc(#loc564)
      %t183 = arith.constant 2 : i32 loc(#loc565)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = memref.load %t11[%t184] : memref<8xi32> loc(#loc566)
      %t186 = arith.constant 0 : i32
      %t187 = arith.constant 5 : i32 loc(#loc567)
      %t188 = arith.constant 0 : i32
      %t189 = arith.shrsi %t185, %t187 : i32 loc(#loc1)
      %t190 = arith.addi %t185, %t189 : i32 loc(#loc568)
      %t191 = arith.constant 2 : i32 loc(#loc569)
      %t192 = arith.constant 0 : i32
      %t193 = arith.shrsi %t190, %t191 : i32 loc(#loc1)
      %t194 = arith.subi %t190, %t193 : i32 loc(#loc570)
      %t195 = arith.constant 6 : i32 loc(#loc571)
      %t196 = arith.index_cast %t195 : i32 to index
      %t197 = memref.load %t11[%t196] : memref<8xi32> loc(#loc572)
      %t198 = arith.constant 0 : i32
      %t199 = arith.constant 5 : i32 loc(#loc560)
      %t200 = arith.constant 0 : i32
      %t201 = arith.shrsi %t197, %t199 : i32 loc(#loc1)
      %t202 = arith.addi %t197, %t201 : i32 loc(#loc561)
      %t203 = arith.constant 2 : i32 loc(#loc562)
      %t204 = arith.constant 0 : i32
      %t205 = arith.shrsi %t202, %t203 : i32 loc(#loc1)
      %t206 = arith.constant 4 : i32 loc(#loc563)
      %t207 = arith.constant 0 : i32
      %t208 = arith.shrsi %t197, %t206 : i32 loc(#loc1)
      %t209 = arith.addi %t205, %t208 : i32 loc(#loc564)
      %t210 = arith.constant 6 : i32 loc(#loc573)
      %t211 = arith.index_cast %t210 : i32 to index
      %t212 = memref.load %t11[%t211] : memref<8xi32> loc(#loc574)
      %t213 = arith.constant 0 : i32
      %t214 = arith.constant 5 : i32 loc(#loc567)
      %t215 = arith.constant 0 : i32
      %t216 = arith.shrsi %t212, %t214 : i32 loc(#loc1)
      %t217 = arith.addi %t212, %t216 : i32 loc(#loc568)
      %t218 = arith.constant 2 : i32 loc(#loc569)
      %t219 = arith.constant 0 : i32
      %t220 = arith.shrsi %t217, %t218 : i32 loc(#loc1)
      %t221 = arith.subi %t217, %t220 : i32 loc(#loc570)
      %t222 = arith.constant 2 : i32 loc(#loc575)
      %t223 = arith.index_cast %t222 : i32 to index
      %t224 = arith.subi %t182, %t221 : i32 loc(#loc576)
      memref.store %t224, %t11[%t223] : memref<8xi32>
      %t225 = arith.constant 6 : i32 loc(#loc577)
      %t226 = arith.index_cast %t225 : i32 to index
      %t227 = arith.addi %t209, %t194 : i32 loc(#loc578)
      memref.store %t227, %t11[%t226] : memref<8xi32>
      %t228 = arith.constant 0 : i32 loc(#loc579)
      %t229 = arith.index_cast %t228 : i32 to index
      %t230 = memref.load %t11[%t229] : memref<8xi32> loc(#loc580)
      %t231 = arith.constant 4 : i32 loc(#loc581)
      %t232 = arith.index_cast %t231 : i32 to index
      %t233 = memref.load %t11[%t232] : memref<8xi32> loc(#loc582)
      %t234 = arith.addi %t230, %t233 : i32 loc(#loc580)
      %t235 = arith.constant 0 : i32 loc(#loc583)
      %t236 = arith.index_cast %t235 : i32 to index
      %t237 = memref.load %t11[%t236] : memref<8xi32> loc(#loc584)
      %t238 = arith.constant 4 : i32 loc(#loc585)
      %t239 = arith.index_cast %t238 : i32 to index
      %t240 = memref.load %t11[%t239] : memref<8xi32> loc(#loc586)
      %t241 = arith.subi %t237, %t240 : i32 loc(#loc584)
      %t242 = arith.constant 0 : i32 loc(#loc587)
      %t243 = arith.index_cast %t242 : i32 to index
      %t244 = arith.constant 6 : i32 loc(#loc588)
      %t245 = arith.index_cast %t244 : i32 to index
      %t246 = memref.load %t11[%t245] : memref<8xi32> loc(#loc589)
      %t247 = arith.addi %t234, %t246 : i32 loc(#loc590)
      memref.store %t247, %t11[%t243] : memref<8xi32>
      %t248 = arith.constant 6 : i32 loc(#loc591)
      %t249 = arith.index_cast %t248 : i32 to index
      %t250 = arith.constant 6 : i32 loc(#loc592)
      %t251 = arith.index_cast %t250 : i32 to index
      %t252 = memref.load %t11[%t251] : memref<8xi32> loc(#loc593)
      %t253 = arith.subi %t234, %t252 : i32 loc(#loc594)
      memref.store %t253, %t11[%t249] : memref<8xi32>
      %t254 = arith.constant 4 : i32 loc(#loc595)
      %t255 = arith.index_cast %t254 : i32 to index
      %t256 = arith.constant 2 : i32 loc(#loc596)
      %t257 = arith.index_cast %t256 : i32 to index
      %t258 = memref.load %t11[%t257] : memref<8xi32> loc(#loc597)
      %t259 = arith.addi %t241, %t258 : i32 loc(#loc598)
      memref.store %t259, %t11[%t255] : memref<8xi32>
      %t260 = arith.constant 2 : i32 loc(#loc599)
      %t261 = arith.index_cast %t260 : i32 to index
      %t262 = arith.constant 2 : i32 loc(#loc600)
      %t263 = arith.index_cast %t262 : i32 to index
      %t264 = memref.load %t11[%t263] : memref<8xi32> loc(#loc601)
      %t265 = arith.subi %t241, %t264 : i32 loc(#loc602)
      memref.store %t265, %t11[%t261] : memref<8xi32>
      %t266 = arith.constant 0 : i32 loc(#loc603)
      %t267 = arith.index_cast %t266 : i32 to index
      %t268 = memref.load %t11[%t267] : memref<8xi32> loc(#loc604)
      %t269 = arith.constant 1 : i32 loc(#loc605)
      %t270 = arith.index_cast %t269 : i32 to index
      %t271 = memref.load %t11[%t270] : memref<8xi32> loc(#loc606)
      %t272 = arith.addi %t268, %t271 : i32 loc(#loc604)
      %t273 = arith.constant 0 : index
      memref.store %t272, %t10[%t273] : memref<8xi32>
      %t274 = arith.constant 4 : i32 loc(#loc607)
      %t275 = arith.index_cast %t274 : i32 to index
      %t276 = memref.load %t11[%t275] : memref<8xi32> loc(#loc608)
      %t277 = arith.constant 5 : i32 loc(#loc609)
      %t278 = arith.index_cast %t277 : i32 to index
      %t279 = memref.load %t11[%t278] : memref<8xi32> loc(#loc610)
      %t280 = arith.addi %t276, %t279 : i32 loc(#loc608)
      %t281 = arith.constant 1 : index
      memref.store %t280, %t10[%t281] : memref<8xi32>
      %t282 = arith.constant 2 : i32 loc(#loc611)
      %t283 = arith.index_cast %t282 : i32 to index
      %t284 = memref.load %t11[%t283] : memref<8xi32> loc(#loc612)
      %t285 = arith.constant 3 : i32 loc(#loc613)
      %t286 = arith.index_cast %t285 : i32 to index
      %t287 = memref.load %t11[%t286] : memref<8xi32> loc(#loc614)
      %t288 = arith.addi %t284, %t287 : i32 loc(#loc612)
      %t289 = arith.constant 2 : index
      memref.store %t288, %t10[%t289] : memref<8xi32>
      %t290 = arith.constant 6 : i32 loc(#loc615)
      %t291 = arith.index_cast %t290 : i32 to index
      %t292 = memref.load %t11[%t291] : memref<8xi32> loc(#loc616)
      %t293 = arith.constant 7 : i32 loc(#loc617)
      %t294 = arith.index_cast %t293 : i32 to index
      %t295 = memref.load %t11[%t294] : memref<8xi32> loc(#loc618)
      %t296 = arith.addi %t292, %t295 : i32 loc(#loc616)
      %t297 = arith.constant 3 : index
      memref.store %t296, %t10[%t297] : memref<8xi32>
      %t298 = arith.constant 6 : i32 loc(#loc619)
      %t299 = arith.index_cast %t298 : i32 to index
      %t300 = memref.load %t11[%t299] : memref<8xi32> loc(#loc620)
      %t301 = arith.constant 7 : i32 loc(#loc621)
      %t302 = arith.index_cast %t301 : i32 to index
      %t303 = memref.load %t11[%t302] : memref<8xi32> loc(#loc622)
      %t304 = arith.subi %t300, %t303 : i32 loc(#loc620)
      %t305 = arith.constant 4 : index
      memref.store %t304, %t10[%t305] : memref<8xi32>
      %t306 = arith.constant 2 : i32 loc(#loc623)
      %t307 = arith.index_cast %t306 : i32 to index
      %t308 = memref.load %t11[%t307] : memref<8xi32> loc(#loc624)
      %t309 = arith.constant 3 : i32 loc(#loc625)
      %t310 = arith.index_cast %t309 : i32 to index
      %t311 = memref.load %t11[%t310] : memref<8xi32> loc(#loc626)
      %t312 = arith.subi %t308, %t311 : i32 loc(#loc624)
      %t313 = arith.constant 5 : index
      memref.store %t312, %t10[%t313] : memref<8xi32>
      %t314 = arith.constant 4 : i32 loc(#loc627)
      %t315 = arith.index_cast %t314 : i32 to index
      %t316 = memref.load %t11[%t315] : memref<8xi32> loc(#loc628)
      %t317 = arith.constant 5 : i32 loc(#loc629)
      %t318 = arith.index_cast %t317 : i32 to index
      %t319 = memref.load %t11[%t318] : memref<8xi32> loc(#loc630)
      %t320 = arith.subi %t316, %t319 : i32 loc(#loc628)
      %t321 = arith.constant 6 : index
      memref.store %t320, %t10[%t321] : memref<8xi32>
      %t322 = arith.constant 0 : i32 loc(#loc631)
      %t323 = arith.index_cast %t322 : i32 to index
      %t324 = memref.load %t11[%t323] : memref<8xi32> loc(#loc632)
      %t325 = arith.constant 1 : i32 loc(#loc633)
      %t326 = arith.index_cast %t325 : i32 to index
      %t327 = memref.load %t11[%t326] : memref<8xi32> loc(#loc634)
      %t328 = arith.subi %t324, %t327 : i32 loc(#loc632)
      %t329 = arith.constant 7 : index
      memref.store %t328, %t10[%t329] : memref<8xi32>
      %t330 = arith.constant 8 : i32 loc(#loc635)
      %t331 = arith.index_cast %t330 : i32 to index
      %t332 = arith.constant 0 : index
      %t333 = arith.constant 1 : index
      scf.for %t334 = %t332 to %t331 step %t333 {
        %t335 = memref.load %t10[%t334] : memref<8xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t335: i32)
        scf.yield
      }
    } loc(#loc493)
  } loc(#loc636)
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_dyn(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc637)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc639)
      %t11 = arith.constant 7 : i32 loc(#loc640)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 0 : i32 loc(#loc641)
      %t17 = arith.constant 7 : i32 loc(#loc642)
      %t18 = arith.index_cast %t16 : i32 to index
      %t19 = arith.index_cast %t17 : i32 to index
      %t20 = arith.constant 1 : index
      %t21 = arith.addi %t19, %t20 : index
      %t22 = arith.constant 1 : index
      scf.for %t23 = %t12 to %t15 step %t22 {
        %t24 = arith.index_cast %t23 : index to i32
        scf.for %t25 = %t18 to %t21 step %t22 {
          %t26 = arith.index_cast %t25 : index to i32
          %t27 = arith.constant 8 : i32 loc(#loc643)
          %t29 = arith.extsi %t27 : i32 to i64
          %t30 = arith.extsi %t26 : i32 to i64
          %t28 = arith.muli %t29, %t30 : i64 loc(#loc643)
          %t31 = arith.extsi %t24 : i32 to i64
          %t32 = arith.addi %t28, %t31 : i64 loc(#loc643)
          %t33 = arith.index_cast %t32 : i64 to index
          %t34 = memref.load %t4[%t33] : memref<64xi32> loc(#loc644)
          fifo.push(%OUT: !fifo.input_port<i32>, %t34: i32)
          scf.yield
        }
        scf.yield
      }
    } loc(#loc638)
  } loc(#loc645)
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_dyn(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc646)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "shift" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc648)
      %t11 = arith.constant 63 : i32 loc(#loc649)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 1 : index
      scf.for %t17 = %t12 to %t15 step %t16 {
        %t18 = arith.index_cast %t17 : index to i32
        %t19 = arith.index_cast %t18 : i32 to index
        %t20 = memref.load %t4[%t19] : memref<64xi32> loc(#loc650)
        %t21 = arith.constant 13 : i32 loc(#loc651)
        %t22 = arith.constant 0 : i32
        %t23 = arith.shrsi %t20, %t21 : i32 loc(#loc1)
        %t24 = arith.constant 128 : i32 loc(#loc652)
        %t25 = arith.addi %t23, %t24 : i32 loc(#loc653)
        %t26 = arith.constant 0 : i32 loc(#loc654)
        %t27 = arith.constant 255 : i32 loc(#loc655)
        %t28 = arith.constant 0 : i8
        %t29 = arith.cmpi sgt, %t25, %t27 : i32 loc(#loc656)
        %t32 = scf.if %t29 -> i32 {
          scf.yield %t27 : i32
        } else {
          %t30 = arith.cmpi slt, %t25, %t26 : i32 loc(#loc657)
          %t31 = scf.if %t30 -> i32 {
            scf.yield %t26 : i32
          } else {
            scf.yield %t25 : i32
          }
          scf.yield %t31 : i32
        }
        %t33 = arith.trunci %t32 : i32 to i8
        fifo.push(%OUT: !fifo.input_port<i8>, %t33: i8)
        scf.yield
      }
    } loc(#loc647)
  } loc(#loc658)
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_0(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t2 = arith.constant 1024 : i32 loc(#loc468)
    cal.set(%t1: !cal.state_ref<i32>, %t2: i32)
    %t3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t4 = arith.constant 1138 : i32 loc(#loc469)
    cal.set(%t3: !cal.state_ref<i32>, %t4: i32)
    %t5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t6 = arith.constant 1730 : i32 loc(#loc470)
    cal.set(%t5: !cal.state_ref<i32>, %t6: i32)
    %t7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t8 = arith.constant 1609 : i32 loc(#loc471)
    cal.set(%t7: !cal.state_ref<i32>, %t8: i32)
    %t9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t10 = arith.constant 1264 : i32 loc(#loc472)
    cal.set(%t9: !cal.state_ref<i32>, %t10: i32)
    %t11 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t12 = arith.constant 1922 : i32 loc(#loc473)
    cal.set(%t11: !cal.state_ref<i32>, %t12: i32)
    %t13 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t14 = arith.constant 1788 : i32 loc(#loc474)
    cal.set(%t13: !cal.state_ref<i32>, %t14: i32)
    %t15 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t16 = arith.constant 2923 : i32 loc(#loc475)
    cal.set(%t15: !cal.state_ref<i32>, %t16: i32)
    %t17 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t18 = arith.constant 2718 : i32 loc(#loc476)
    cal.set(%t17: !cal.state_ref<i32>, %t18: i32)
    %t19 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t20 = arith.constant 2528 : i32 loc(#loc477)
    cal.set(%t19: !cal.state_ref<i32>, %t20: i32)
    %t21 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %t22 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %t23 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %t23, %t22 : memref<64xi16> to memref<64xi16>
    %t24 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t25 = arith.constant 0 : i32 loc(#loc478)
    %t26 = arith.extsi %t25 : i32 to i64
    cal.set(%t24: !cal.state_ref<i64>, %t26: i64)
    cal.action "scale" priority=0 {
      %t27 = memref.alloca() : memref<64xi32>
      %t28 = memref.alloca() : memref<64xi13>
      %t29 = arith.constant 64 : index
      %t30 = arith.constant 0 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t30 to %t29 step %t31 {
        %t33 = fifo.pop(%IN: !fifo.output_port<i13> ) : i13
        memref.store %t33, %t28[%t32] : memref<64xi13>
        scf.yield
      }
      %t34 = arith.constant 0 : i32 loc(#loc480)
      %t35 = arith.constant 63 : i32 loc(#loc481)
      %t36 = arith.index_cast %t34 : i32 to index
      %t37 = arith.index_cast %t35 : i32 to index
      %t38 = arith.constant 1 : index
      %t39 = arith.addi %t37, %t38 : index
      %t40 = arith.constant 1 : index
      scf.for %t41 = %t36 to %t39 step %t40 {
        %t42 = arith.index_cast %t41 : index to i32
        %t43 = arith.index_cast %t42 : i32 to index
        %t44 = memref.load %t28[%t43] : memref<64xi13> loc(#loc482)
        %t45 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %t46 = arith.index_cast %t42 : i32 to index
        %t47 = memref.load %t45[%t46] : memref<64xi16> loc(#loc483)
        %t48 = arith.extsi %t44 : i13 to i16
        %t50 = arith.extsi %t48 : i16 to i32
        %t51 = arith.extsi %t47 : i16 to i32
        %t49 = arith.muli %t50, %t51 : i32 loc(#loc482)
        %t52 = arith.subi %t41, %t36 : index
        memref.store %t49, %t27[%t52] : memref<64xi32>
        scf.yield
      }
      %t53 = arith.constant 0 : i32 loc(#loc484)
      %t54 = arith.index_cast %t53 : i32 to index
      %t55 = arith.constant 0 : i32 loc(#loc485)
      %t56 = arith.index_cast %t55 : i32 to index
      %t57 = memref.load %t27[%t56] : memref<64xi32> loc(#loc486)
      %t58 = arith.constant 4096 : i32 loc(#loc487)
      %t59 = arith.addi %t57, %t58 : i32 loc(#loc486)
      memref.store %t59, %t27[%t54] : memref<64xi32>
      %t60 = cal.get(%t24: !cal.state_ref<i64>) : i64
      %t61 = arith.constant 64 : i32 loc(#loc488)
      %t62 = arith.extsi %t61 : i32 to i64
      %t63 = arith.addi %t60, %t62 : i64 loc(#loc489)
      cal.set(%t24: !cal.state_ref<i64>, %t63: i64)
      %t64 = arith.constant 64 : i32 loc(#loc490)
      %t65 = arith.index_cast %t64 : i32 to index
      %t66 = arith.constant 0 : index
      %t67 = arith.constant 1 : index
      scf.for %t68 = %t66 to %t65 step %t67 {
        %t69 = memref.load %t27[%t68] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t69: i32)
        scf.yield
      }
    } loc(#loc479)
  } loc(#loc491)
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_0(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc492)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = arith.constant 0 : i32
      %t5 = arith.constant 0 : i32
      %t6 = arith.constant 0 : i32
      %t7 = arith.constant 0 : i32
      %t8 = arith.constant 0 : i32
      %t9 = arith.constant 0 : i32
      %t10 = memref.alloca() : memref<8xi32>
      %t11 = memref.alloca() : memref<8xi32>
      %t12 = memref.alloca() : memref<8xi32>
      %t13 = arith.constant 8 : index
      %t14 = arith.constant 0 : index
      %t15 = arith.constant 1 : index
      scf.for %t16 = %t14 to %t13 step %t15 {
        %t17 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t17, %t12[%t16] : memref<8xi32>
        scf.yield
      }
      memref.copy %t12, %t11 : memref<8xi32> to memref<8xi32>
      %t18 = arith.constant 1 : i32 loc(#loc494)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = memref.load %t11[%t19] : memref<8xi32> loc(#loc495)
      %t21 = arith.constant 7 : i32 loc(#loc496)
      %t22 = arith.index_cast %t21 : i32 to index
      %t23 = memref.load %t11[%t22] : memref<8xi32> loc(#loc497)
      %t24 = arith.addi %t20, %t23 : i32 loc(#loc495)
      %t25 = arith.constant 1 : i32 loc(#loc498)
      %t26 = arith.index_cast %t25 : i32 to index
      %t27 = memref.load %t11[%t26] : memref<8xi32> loc(#loc499)
      %t28 = arith.constant 7 : i32 loc(#loc500)
      %t29 = arith.index_cast %t28 : i32 to index
      %t30 = memref.load %t11[%t29] : memref<8xi32> loc(#loc501)
      %t31 = arith.subi %t27, %t30 : i32 loc(#loc499)
      %t32 = arith.constant 1 : i32 loc(#loc502)
      %t33 = arith.index_cast %t32 : i32 to index
      %t34 = arith.constant 3 : i32 loc(#loc503)
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = memref.load %t11[%t35] : memref<8xi32> loc(#loc504)
      %t37 = arith.addi %t24, %t36 : i32 loc(#loc505)
      memref.store %t37, %t11[%t33] : memref<8xi32>
      %t38 = arith.constant 3 : i32 loc(#loc506)
      %t39 = arith.index_cast %t38 : i32 to index
      %t40 = arith.constant 3 : i32 loc(#loc507)
      %t41 = arith.index_cast %t40 : i32 to index
      %t42 = memref.load %t11[%t41] : memref<8xi32> loc(#loc508)
      %t43 = arith.subi %t24, %t42 : i32 loc(#loc509)
      memref.store %t43, %t11[%t39] : memref<8xi32>
      %t44 = arith.constant 7 : i32 loc(#loc510)
      %t45 = arith.index_cast %t44 : i32 to index
      %t46 = arith.constant 5 : i32 loc(#loc511)
      %t47 = arith.index_cast %t46 : i32 to index
      %t48 = memref.load %t11[%t47] : memref<8xi32> loc(#loc512)
      %t49 = arith.addi %t31, %t48 : i32 loc(#loc513)
      memref.store %t49, %t11[%t45] : memref<8xi32>
      %t50 = arith.constant 5 : i32 loc(#loc514)
      %t51 = arith.index_cast %t50 : i32 to index
      %t52 = arith.constant 5 : i32 loc(#loc515)
      %t53 = arith.index_cast %t52 : i32 to index
      %t54 = memref.load %t11[%t53] : memref<8xi32> loc(#loc516)
      %t55 = arith.subi %t31, %t54 : i32 loc(#loc517)
      memref.store %t55, %t11[%t51] : memref<8xi32>
      %t56 = arith.constant 3 : i32 loc(#loc518)
      %t57 = arith.index_cast %t56 : i32 to index
      %t58 = memref.load %t11[%t57] : memref<8xi32> loc(#loc519)
      %t59 = arith.constant 0 : i32
      %t60 = arith.constant 3 : i32 loc(#loc520)
      %t61 = arith.constant 0 : i32
      %t62 = arith.shrsi %t58, %t60 : i32 loc(#loc1)
      %t63 = arith.constant 7 : i32 loc(#loc521)
      %t64 = arith.constant 0 : i32
      %t65 = arith.shrsi %t58, %t63 : i32 loc(#loc1)
      %t66 = arith.subi %t62, %t65 : i32 loc(#loc522)
      %t67 = arith.subi %t58, %t66 : i32 loc(#loc523)
      %t68 = arith.constant 3 : i32 loc(#loc524)
      %t69 = arith.index_cast %t68 : i32 to index
      %t70 = memref.load %t11[%t69] : memref<8xi32> loc(#loc525)
      %t71 = arith.constant 0 : i32
      %t72 = arith.constant 3 : i32 loc(#loc526)
      %t73 = arith.constant 0 : i32
      %t74 = arith.shrsi %t70, %t72 : i32 loc(#loc1)
      %t75 = arith.constant 7 : i32 loc(#loc527)
      %t76 = arith.constant 0 : i32
      %t77 = arith.shrsi %t70, %t75 : i32 loc(#loc1)
      %t78 = arith.subi %t74, %t77 : i32 loc(#loc528)
      %t79 = arith.constant 11 : i32 loc(#loc529)
      %t80 = arith.constant 0 : i32
      %t81 = arith.shrsi %t70, %t79 : i32 loc(#loc1)
      %t82 = arith.subi %t78, %t81 : i32 loc(#loc530)
      %t83 = arith.constant 1 : i32 loc(#loc531)
      %t84 = arith.constant 0 : i32
      %t85 = arith.shrsi %t82, %t83 : i32 loc(#loc1)
      %t86 = arith.addi %t78, %t85 : i32 loc(#loc532)
      %t87 = arith.constant 5 : i32 loc(#loc533)
      %t88 = arith.index_cast %t87 : i32 to index
      %t89 = memref.load %t11[%t88] : memref<8xi32> loc(#loc534)
      %t90 = arith.constant 0 : i32
      %t91 = arith.constant 3 : i32 loc(#loc520)
      %t92 = arith.constant 0 : i32
      %t93 = arith.shrsi %t89, %t91 : i32 loc(#loc1)
      %t94 = arith.constant 7 : i32 loc(#loc521)
      %t95 = arith.constant 0 : i32
      %t96 = arith.shrsi %t89, %t94 : i32 loc(#loc1)
      %t97 = arith.subi %t93, %t96 : i32 loc(#loc522)
      %t98 = arith.subi %t89, %t97 : i32 loc(#loc523)
      %t99 = arith.constant 5 : i32 loc(#loc535)
      %t100 = arith.index_cast %t99 : i32 to index
      %t101 = memref.load %t11[%t100] : memref<8xi32> loc(#loc536)
      %t102 = arith.constant 0 : i32
      %t103 = arith.constant 3 : i32 loc(#loc526)
      %t104 = arith.constant 0 : i32
      %t105 = arith.shrsi %t101, %t103 : i32 loc(#loc1)
      %t106 = arith.constant 7 : i32 loc(#loc527)
      %t107 = arith.constant 0 : i32
      %t108 = arith.shrsi %t101, %t106 : i32 loc(#loc1)
      %t109 = arith.subi %t105, %t108 : i32 loc(#loc528)
      %t110 = arith.constant 11 : i32 loc(#loc529)
      %t111 = arith.constant 0 : i32
      %t112 = arith.shrsi %t101, %t110 : i32 loc(#loc1)
      %t113 = arith.subi %t109, %t112 : i32 loc(#loc530)
      %t114 = arith.constant 1 : i32 loc(#loc531)
      %t115 = arith.constant 0 : i32
      %t116 = arith.shrsi %t113, %t114 : i32 loc(#loc1)
      %t117 = arith.addi %t109, %t116 : i32 loc(#loc532)
      %t118 = arith.constant 3 : i32 loc(#loc537)
      %t119 = arith.index_cast %t118 : i32 to index
      %t120 = arith.subi %t67, %t117 : i32 loc(#loc538)
      memref.store %t120, %t11[%t119] : memref<8xi32>
      %t121 = arith.constant 5 : i32 loc(#loc539)
      %t122 = arith.index_cast %t121 : i32 to index
      %t123 = arith.addi %t98, %t86 : i32 loc(#loc540)
      memref.store %t123, %t11[%t122] : memref<8xi32>
      %t124 = arith.constant 1 : i32 loc(#loc541)
      %t125 = arith.index_cast %t124 : i32 to index
      %t126 = memref.load %t11[%t125] : memref<8xi32> loc(#loc542)
      %t127 = arith.constant 0 : i32
      %t128 = arith.constant 9 : i32 loc(#loc543)
      %t129 = arith.constant 0 : i32
      %t130 = arith.shrsi %t126, %t128 : i32 loc(#loc1)
      %t131 = arith.subi %t130, %t126 : i32 loc(#loc544)
      %t132 = arith.constant 2 : i32 loc(#loc545)
      %t133 = arith.constant 0 : i32
      %t134 = arith.shrsi %t131, %t132 : i32 loc(#loc1)
      %t135 = arith.subi %t134, %t131 : i32 loc(#loc546)
      %t136 = arith.constant 1 : i32 loc(#loc547)
      %t137 = arith.index_cast %t136 : i32 to index
      %t138 = memref.load %t11[%t137] : memref<8xi32> loc(#loc548)
      %t139 = arith.constant 0 : i32
      %t140 = arith.constant 1 : i32 loc(#loc549)
      %t141 = arith.constant 0 : i32
      %t142 = arith.shrsi %t138, %t140 : i32 loc(#loc1)
      %t143 = arith.constant 7 : i32 loc(#loc550)
      %t144 = arith.index_cast %t143 : i32 to index
      %t145 = memref.load %t11[%t144] : memref<8xi32> loc(#loc551)
      %t146 = arith.constant 0 : i32
      %t147 = arith.constant 9 : i32 loc(#loc543)
      %t148 = arith.constant 0 : i32
      %t149 = arith.shrsi %t145, %t147 : i32 loc(#loc1)
      %t150 = arith.subi %t149, %t145 : i32 loc(#loc544)
      %t151 = arith.constant 2 : i32 loc(#loc545)
      %t152 = arith.constant 0 : i32
      %t153 = arith.shrsi %t150, %t151 : i32 loc(#loc1)
      %t154 = arith.subi %t153, %t150 : i32 loc(#loc546)
      %t155 = arith.constant 7 : i32 loc(#loc552)
      %t156 = arith.index_cast %t155 : i32 to index
      %t157 = memref.load %t11[%t156] : memref<8xi32> loc(#loc553)
      %t158 = arith.constant 0 : i32
      %t159 = arith.constant 1 : i32 loc(#loc549)
      %t160 = arith.constant 0 : i32
      %t161 = arith.shrsi %t157, %t159 : i32 loc(#loc1)
      %t162 = arith.constant 1 : i32 loc(#loc554)
      %t163 = arith.index_cast %t162 : i32 to index
      %t164 = arith.addi %t135, %t161 : i32 loc(#loc555)
      memref.store %t164, %t11[%t163] : memref<8xi32>
      %t165 = arith.constant 7 : i32 loc(#loc556)
      %t166 = arith.index_cast %t165 : i32 to index
      %t167 = arith.subi %t154, %t142 : i32 loc(#loc557)
      memref.store %t167, %t11[%t166] : memref<8xi32>
      %t168 = arith.constant 2 : i32 loc(#loc558)
      %t169 = arith.index_cast %t168 : i32 to index
      %t170 = memref.load %t11[%t169] : memref<8xi32> loc(#loc559)
      %t171 = arith.constant 0 : i32
      %t172 = arith.constant 5 : i32 loc(#loc560)
      %t173 = arith.constant 0 : i32
      %t174 = arith.shrsi %t170, %t172 : i32 loc(#loc1)
      %t175 = arith.addi %t170, %t174 : i32 loc(#loc561)
      %t176 = arith.constant 2 : i32 loc(#loc562)
      %t177 = arith.constant 0 : i32
      %t178 = arith.shrsi %t175, %t176 : i32 loc(#loc1)
      %t179 = arith.constant 4 : i32 loc(#loc563)
      %t180 = arith.constant 0 : i32
      %t181 = arith.shrsi %t170, %t179 : i32 loc(#loc1)
      %t182 = arith.addi %t178, %t181 : i32 loc(#loc564)
      %t183 = arith.constant 2 : i32 loc(#loc565)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = memref.load %t11[%t184] : memref<8xi32> loc(#loc566)
      %t186 = arith.constant 0 : i32
      %t187 = arith.constant 5 : i32 loc(#loc567)
      %t188 = arith.constant 0 : i32
      %t189 = arith.shrsi %t185, %t187 : i32 loc(#loc1)
      %t190 = arith.addi %t185, %t189 : i32 loc(#loc568)
      %t191 = arith.constant 2 : i32 loc(#loc569)
      %t192 = arith.constant 0 : i32
      %t193 = arith.shrsi %t190, %t191 : i32 loc(#loc1)
      %t194 = arith.subi %t190, %t193 : i32 loc(#loc570)
      %t195 = arith.constant 6 : i32 loc(#loc571)
      %t196 = arith.index_cast %t195 : i32 to index
      %t197 = memref.load %t11[%t196] : memref<8xi32> loc(#loc572)
      %t198 = arith.constant 0 : i32
      %t199 = arith.constant 5 : i32 loc(#loc560)
      %t200 = arith.constant 0 : i32
      %t201 = arith.shrsi %t197, %t199 : i32 loc(#loc1)
      %t202 = arith.addi %t197, %t201 : i32 loc(#loc561)
      %t203 = arith.constant 2 : i32 loc(#loc562)
      %t204 = arith.constant 0 : i32
      %t205 = arith.shrsi %t202, %t203 : i32 loc(#loc1)
      %t206 = arith.constant 4 : i32 loc(#loc563)
      %t207 = arith.constant 0 : i32
      %t208 = arith.shrsi %t197, %t206 : i32 loc(#loc1)
      %t209 = arith.addi %t205, %t208 : i32 loc(#loc564)
      %t210 = arith.constant 6 : i32 loc(#loc573)
      %t211 = arith.index_cast %t210 : i32 to index
      %t212 = memref.load %t11[%t211] : memref<8xi32> loc(#loc574)
      %t213 = arith.constant 0 : i32
      %t214 = arith.constant 5 : i32 loc(#loc567)
      %t215 = arith.constant 0 : i32
      %t216 = arith.shrsi %t212, %t214 : i32 loc(#loc1)
      %t217 = arith.addi %t212, %t216 : i32 loc(#loc568)
      %t218 = arith.constant 2 : i32 loc(#loc569)
      %t219 = arith.constant 0 : i32
      %t220 = arith.shrsi %t217, %t218 : i32 loc(#loc1)
      %t221 = arith.subi %t217, %t220 : i32 loc(#loc570)
      %t222 = arith.constant 2 : i32 loc(#loc575)
      %t223 = arith.index_cast %t222 : i32 to index
      %t224 = arith.subi %t182, %t221 : i32 loc(#loc576)
      memref.store %t224, %t11[%t223] : memref<8xi32>
      %t225 = arith.constant 6 : i32 loc(#loc577)
      %t226 = arith.index_cast %t225 : i32 to index
      %t227 = arith.addi %t209, %t194 : i32 loc(#loc578)
      memref.store %t227, %t11[%t226] : memref<8xi32>
      %t228 = arith.constant 0 : i32 loc(#loc579)
      %t229 = arith.index_cast %t228 : i32 to index
      %t230 = memref.load %t11[%t229] : memref<8xi32> loc(#loc580)
      %t231 = arith.constant 4 : i32 loc(#loc581)
      %t232 = arith.index_cast %t231 : i32 to index
      %t233 = memref.load %t11[%t232] : memref<8xi32> loc(#loc582)
      %t234 = arith.addi %t230, %t233 : i32 loc(#loc580)
      %t235 = arith.constant 0 : i32 loc(#loc583)
      %t236 = arith.index_cast %t235 : i32 to index
      %t237 = memref.load %t11[%t236] : memref<8xi32> loc(#loc584)
      %t238 = arith.constant 4 : i32 loc(#loc585)
      %t239 = arith.index_cast %t238 : i32 to index
      %t240 = memref.load %t11[%t239] : memref<8xi32> loc(#loc586)
      %t241 = arith.subi %t237, %t240 : i32 loc(#loc584)
      %t242 = arith.constant 0 : i32 loc(#loc587)
      %t243 = arith.index_cast %t242 : i32 to index
      %t244 = arith.constant 6 : i32 loc(#loc588)
      %t245 = arith.index_cast %t244 : i32 to index
      %t246 = memref.load %t11[%t245] : memref<8xi32> loc(#loc589)
      %t247 = arith.addi %t234, %t246 : i32 loc(#loc590)
      memref.store %t247, %t11[%t243] : memref<8xi32>
      %t248 = arith.constant 6 : i32 loc(#loc591)
      %t249 = arith.index_cast %t248 : i32 to index
      %t250 = arith.constant 6 : i32 loc(#loc592)
      %t251 = arith.index_cast %t250 : i32 to index
      %t252 = memref.load %t11[%t251] : memref<8xi32> loc(#loc593)
      %t253 = arith.subi %t234, %t252 : i32 loc(#loc594)
      memref.store %t253, %t11[%t249] : memref<8xi32>
      %t254 = arith.constant 4 : i32 loc(#loc595)
      %t255 = arith.index_cast %t254 : i32 to index
      %t256 = arith.constant 2 : i32 loc(#loc596)
      %t257 = arith.index_cast %t256 : i32 to index
      %t258 = memref.load %t11[%t257] : memref<8xi32> loc(#loc597)
      %t259 = arith.addi %t241, %t258 : i32 loc(#loc598)
      memref.store %t259, %t11[%t255] : memref<8xi32>
      %t260 = arith.constant 2 : i32 loc(#loc599)
      %t261 = arith.index_cast %t260 : i32 to index
      %t262 = arith.constant 2 : i32 loc(#loc600)
      %t263 = arith.index_cast %t262 : i32 to index
      %t264 = memref.load %t11[%t263] : memref<8xi32> loc(#loc601)
      %t265 = arith.subi %t241, %t264 : i32 loc(#loc602)
      memref.store %t265, %t11[%t261] : memref<8xi32>
      %t266 = arith.constant 0 : i32 loc(#loc603)
      %t267 = arith.index_cast %t266 : i32 to index
      %t268 = memref.load %t11[%t267] : memref<8xi32> loc(#loc604)
      %t269 = arith.constant 1 : i32 loc(#loc605)
      %t270 = arith.index_cast %t269 : i32 to index
      %t271 = memref.load %t11[%t270] : memref<8xi32> loc(#loc606)
      %t272 = arith.addi %t268, %t271 : i32 loc(#loc604)
      %t273 = arith.constant 0 : index
      memref.store %t272, %t10[%t273] : memref<8xi32>
      %t274 = arith.constant 4 : i32 loc(#loc607)
      %t275 = arith.index_cast %t274 : i32 to index
      %t276 = memref.load %t11[%t275] : memref<8xi32> loc(#loc608)
      %t277 = arith.constant 5 : i32 loc(#loc609)
      %t278 = arith.index_cast %t277 : i32 to index
      %t279 = memref.load %t11[%t278] : memref<8xi32> loc(#loc610)
      %t280 = arith.addi %t276, %t279 : i32 loc(#loc608)
      %t281 = arith.constant 1 : index
      memref.store %t280, %t10[%t281] : memref<8xi32>
      %t282 = arith.constant 2 : i32 loc(#loc611)
      %t283 = arith.index_cast %t282 : i32 to index
      %t284 = memref.load %t11[%t283] : memref<8xi32> loc(#loc612)
      %t285 = arith.constant 3 : i32 loc(#loc613)
      %t286 = arith.index_cast %t285 : i32 to index
      %t287 = memref.load %t11[%t286] : memref<8xi32> loc(#loc614)
      %t288 = arith.addi %t284, %t287 : i32 loc(#loc612)
      %t289 = arith.constant 2 : index
      memref.store %t288, %t10[%t289] : memref<8xi32>
      %t290 = arith.constant 6 : i32 loc(#loc615)
      %t291 = arith.index_cast %t290 : i32 to index
      %t292 = memref.load %t11[%t291] : memref<8xi32> loc(#loc616)
      %t293 = arith.constant 7 : i32 loc(#loc617)
      %t294 = arith.index_cast %t293 : i32 to index
      %t295 = memref.load %t11[%t294] : memref<8xi32> loc(#loc618)
      %t296 = arith.addi %t292, %t295 : i32 loc(#loc616)
      %t297 = arith.constant 3 : index
      memref.store %t296, %t10[%t297] : memref<8xi32>
      %t298 = arith.constant 6 : i32 loc(#loc619)
      %t299 = arith.index_cast %t298 : i32 to index
      %t300 = memref.load %t11[%t299] : memref<8xi32> loc(#loc620)
      %t301 = arith.constant 7 : i32 loc(#loc621)
      %t302 = arith.index_cast %t301 : i32 to index
      %t303 = memref.load %t11[%t302] : memref<8xi32> loc(#loc622)
      %t304 = arith.subi %t300, %t303 : i32 loc(#loc620)
      %t305 = arith.constant 4 : index
      memref.store %t304, %t10[%t305] : memref<8xi32>
      %t306 = arith.constant 2 : i32 loc(#loc623)
      %t307 = arith.index_cast %t306 : i32 to index
      %t308 = memref.load %t11[%t307] : memref<8xi32> loc(#loc624)
      %t309 = arith.constant 3 : i32 loc(#loc625)
      %t310 = arith.index_cast %t309 : i32 to index
      %t311 = memref.load %t11[%t310] : memref<8xi32> loc(#loc626)
      %t312 = arith.subi %t308, %t311 : i32 loc(#loc624)
      %t313 = arith.constant 5 : index
      memref.store %t312, %t10[%t313] : memref<8xi32>
      %t314 = arith.constant 4 : i32 loc(#loc627)
      %t315 = arith.index_cast %t314 : i32 to index
      %t316 = memref.load %t11[%t315] : memref<8xi32> loc(#loc628)
      %t317 = arith.constant 5 : i32 loc(#loc629)
      %t318 = arith.index_cast %t317 : i32 to index
      %t319 = memref.load %t11[%t318] : memref<8xi32> loc(#loc630)
      %t320 = arith.subi %t316, %t319 : i32 loc(#loc628)
      %t321 = arith.constant 6 : index
      memref.store %t320, %t10[%t321] : memref<8xi32>
      %t322 = arith.constant 0 : i32 loc(#loc631)
      %t323 = arith.index_cast %t322 : i32 to index
      %t324 = memref.load %t11[%t323] : memref<8xi32> loc(#loc632)
      %t325 = arith.constant 1 : i32 loc(#loc633)
      %t326 = arith.index_cast %t325 : i32 to index
      %t327 = memref.load %t11[%t326] : memref<8xi32> loc(#loc634)
      %t328 = arith.subi %t324, %t327 : i32 loc(#loc632)
      %t329 = arith.constant 7 : index
      memref.store %t328, %t10[%t329] : memref<8xi32>
      %t330 = arith.constant 8 : i32 loc(#loc635)
      %t331 = arith.index_cast %t330 : i32 to index
      %t332 = arith.constant 0 : index
      %t333 = arith.constant 1 : index
      scf.for %t334 = %t332 to %t331 step %t333 {
        %t335 = memref.load %t10[%t334] : memref<8xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t335: i32)
        scf.yield
      }
    } loc(#loc493)
  } loc(#loc636)
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_0(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc637)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc639)
      %t11 = arith.constant 7 : i32 loc(#loc640)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 0 : i32 loc(#loc641)
      %t17 = arith.constant 7 : i32 loc(#loc642)
      %t18 = arith.index_cast %t16 : i32 to index
      %t19 = arith.index_cast %t17 : i32 to index
      %t20 = arith.constant 1 : index
      %t21 = arith.addi %t19, %t20 : index
      %t22 = arith.constant 1 : index
      scf.for %t23 = %t12 to %t15 step %t22 {
        %t24 = arith.index_cast %t23 : index to i32
        scf.for %t25 = %t18 to %t21 step %t22 {
          %t26 = arith.index_cast %t25 : index to i32
          %t27 = arith.constant 8 : i32 loc(#loc643)
          %t29 = arith.extsi %t27 : i32 to i64
          %t30 = arith.extsi %t26 : i32 to i64
          %t28 = arith.muli %t29, %t30 : i64 loc(#loc643)
          %t31 = arith.extsi %t24 : i32 to i64
          %t32 = arith.addi %t28, %t31 : i64 loc(#loc643)
          %t33 = arith.index_cast %t32 : i64 to index
          %t34 = memref.load %t4[%t33] : memref<64xi32> loc(#loc644)
          fifo.push(%OUT: !fifo.input_port<i32>, %t34: i32)
          scf.yield
        }
        scf.yield
      }
    } loc(#loc638)
  } loc(#loc645)
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_0(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc646)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "shift" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc648)
      %t11 = arith.constant 63 : i32 loc(#loc649)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 1 : index
      scf.for %t17 = %t12 to %t15 step %t16 {
        %t18 = arith.index_cast %t17 : index to i32
        %t19 = arith.index_cast %t18 : i32 to index
        %t20 = memref.load %t4[%t19] : memref<64xi32> loc(#loc650)
        %t21 = arith.constant 13 : i32 loc(#loc651)
        %t22 = arith.constant 0 : i32
        %t23 = arith.shrsi %t20, %t21 : i32 loc(#loc1)
        %t24 = arith.constant 128 : i32 loc(#loc652)
        %t25 = arith.addi %t23, %t24 : i32 loc(#loc653)
        %t26 = arith.constant 0 : i32 loc(#loc654)
        %t27 = arith.constant 255 : i32 loc(#loc655)
        %t28 = arith.constant 0 : i8
        %t29 = arith.cmpi sgt, %t25, %t27 : i32 loc(#loc656)
        %t32 = scf.if %t29 -> i32 {
          scf.yield %t27 : i32
        } else {
          %t30 = arith.cmpi slt, %t25, %t26 : i32 loc(#loc657)
          %t31 = scf.if %t30 -> i32 {
            scf.yield %t26 : i32
          } else {
            scf.yield %t25 : i32
          }
          scf.yield %t31 : i32
        }
        %t33 = arith.trunci %t32 : i32 to i8
        fifo.push(%OUT: !fifo.input_port<i8>, %t33: i8)
        scf.yield
      }
    } loc(#loc647)
  } loc(#loc658)
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_1(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t2 = arith.constant 1024 : i32 loc(#loc468)
    cal.set(%t1: !cal.state_ref<i32>, %t2: i32)
    %t3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t4 = arith.constant 1138 : i32 loc(#loc469)
    cal.set(%t3: !cal.state_ref<i32>, %t4: i32)
    %t5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t6 = arith.constant 1730 : i32 loc(#loc470)
    cal.set(%t5: !cal.state_ref<i32>, %t6: i32)
    %t7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t8 = arith.constant 1609 : i32 loc(#loc471)
    cal.set(%t7: !cal.state_ref<i32>, %t8: i32)
    %t9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t10 = arith.constant 1264 : i32 loc(#loc472)
    cal.set(%t9: !cal.state_ref<i32>, %t10: i32)
    %t11 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t12 = arith.constant 1922 : i32 loc(#loc473)
    cal.set(%t11: !cal.state_ref<i32>, %t12: i32)
    %t13 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t14 = arith.constant 1788 : i32 loc(#loc474)
    cal.set(%t13: !cal.state_ref<i32>, %t14: i32)
    %t15 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t16 = arith.constant 2923 : i32 loc(#loc475)
    cal.set(%t15: !cal.state_ref<i32>, %t16: i32)
    %t17 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t18 = arith.constant 2718 : i32 loc(#loc476)
    cal.set(%t17: !cal.state_ref<i32>, %t18: i32)
    %t19 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t20 = arith.constant 2528 : i32 loc(#loc477)
    cal.set(%t19: !cal.state_ref<i32>, %t20: i32)
    %t21 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %t22 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %t23 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %t23, %t22 : memref<64xi16> to memref<64xi16>
    %t24 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t25 = arith.constant 0 : i32 loc(#loc478)
    %t26 = arith.extsi %t25 : i32 to i64
    cal.set(%t24: !cal.state_ref<i64>, %t26: i64)
    cal.action "scale" priority=0 {
      %t27 = memref.alloca() : memref<64xi32>
      %t28 = memref.alloca() : memref<64xi13>
      %t29 = arith.constant 64 : index
      %t30 = arith.constant 0 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t30 to %t29 step %t31 {
        %t33 = fifo.pop(%IN: !fifo.output_port<i13> ) : i13
        memref.store %t33, %t28[%t32] : memref<64xi13>
        scf.yield
      }
      %t34 = arith.constant 0 : i32 loc(#loc480)
      %t35 = arith.constant 63 : i32 loc(#loc481)
      %t36 = arith.index_cast %t34 : i32 to index
      %t37 = arith.index_cast %t35 : i32 to index
      %t38 = arith.constant 1 : index
      %t39 = arith.addi %t37, %t38 : index
      %t40 = arith.constant 1 : index
      scf.for %t41 = %t36 to %t39 step %t40 {
        %t42 = arith.index_cast %t41 : index to i32
        %t43 = arith.index_cast %t42 : i32 to index
        %t44 = memref.load %t28[%t43] : memref<64xi13> loc(#loc482)
        %t45 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %t46 = arith.index_cast %t42 : i32 to index
        %t47 = memref.load %t45[%t46] : memref<64xi16> loc(#loc483)
        %t48 = arith.extsi %t44 : i13 to i16
        %t50 = arith.extsi %t48 : i16 to i32
        %t51 = arith.extsi %t47 : i16 to i32
        %t49 = arith.muli %t50, %t51 : i32 loc(#loc482)
        %t52 = arith.subi %t41, %t36 : index
        memref.store %t49, %t27[%t52] : memref<64xi32>
        scf.yield
      }
      %t53 = arith.constant 0 : i32 loc(#loc484)
      %t54 = arith.index_cast %t53 : i32 to index
      %t55 = arith.constant 0 : i32 loc(#loc485)
      %t56 = arith.index_cast %t55 : i32 to index
      %t57 = memref.load %t27[%t56] : memref<64xi32> loc(#loc486)
      %t58 = arith.constant 4096 : i32 loc(#loc487)
      %t59 = arith.addi %t57, %t58 : i32 loc(#loc486)
      memref.store %t59, %t27[%t54] : memref<64xi32>
      %t60 = cal.get(%t24: !cal.state_ref<i64>) : i64
      %t61 = arith.constant 64 : i32 loc(#loc488)
      %t62 = arith.extsi %t61 : i32 to i64
      %t63 = arith.addi %t60, %t62 : i64 loc(#loc489)
      cal.set(%t24: !cal.state_ref<i64>, %t63: i64)
      %t64 = arith.constant 64 : i32 loc(#loc490)
      %t65 = arith.index_cast %t64 : i32 to index
      %t66 = arith.constant 0 : index
      %t67 = arith.constant 1 : index
      scf.for %t68 = %t66 to %t65 step %t67 {
        %t69 = memref.load %t27[%t68] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t69: i32)
        scf.yield
      }
    } loc(#loc479)
  } loc(#loc491)
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_1(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc492)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = arith.constant 0 : i32
      %t5 = arith.constant 0 : i32
      %t6 = arith.constant 0 : i32
      %t7 = arith.constant 0 : i32
      %t8 = arith.constant 0 : i32
      %t9 = arith.constant 0 : i32
      %t10 = memref.alloca() : memref<8xi32>
      %t11 = memref.alloca() : memref<8xi32>
      %t12 = memref.alloca() : memref<8xi32>
      %t13 = arith.constant 8 : index
      %t14 = arith.constant 0 : index
      %t15 = arith.constant 1 : index
      scf.for %t16 = %t14 to %t13 step %t15 {
        %t17 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t17, %t12[%t16] : memref<8xi32>
        scf.yield
      }
      memref.copy %t12, %t11 : memref<8xi32> to memref<8xi32>
      %t18 = arith.constant 1 : i32 loc(#loc494)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = memref.load %t11[%t19] : memref<8xi32> loc(#loc495)
      %t21 = arith.constant 7 : i32 loc(#loc496)
      %t22 = arith.index_cast %t21 : i32 to index
      %t23 = memref.load %t11[%t22] : memref<8xi32> loc(#loc497)
      %t24 = arith.addi %t20, %t23 : i32 loc(#loc495)
      %t25 = arith.constant 1 : i32 loc(#loc498)
      %t26 = arith.index_cast %t25 : i32 to index
      %t27 = memref.load %t11[%t26] : memref<8xi32> loc(#loc499)
      %t28 = arith.constant 7 : i32 loc(#loc500)
      %t29 = arith.index_cast %t28 : i32 to index
      %t30 = memref.load %t11[%t29] : memref<8xi32> loc(#loc501)
      %t31 = arith.subi %t27, %t30 : i32 loc(#loc499)
      %t32 = arith.constant 1 : i32 loc(#loc502)
      %t33 = arith.index_cast %t32 : i32 to index
      %t34 = arith.constant 3 : i32 loc(#loc503)
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = memref.load %t11[%t35] : memref<8xi32> loc(#loc504)
      %t37 = arith.addi %t24, %t36 : i32 loc(#loc505)
      memref.store %t37, %t11[%t33] : memref<8xi32>
      %t38 = arith.constant 3 : i32 loc(#loc506)
      %t39 = arith.index_cast %t38 : i32 to index
      %t40 = arith.constant 3 : i32 loc(#loc507)
      %t41 = arith.index_cast %t40 : i32 to index
      %t42 = memref.load %t11[%t41] : memref<8xi32> loc(#loc508)
      %t43 = arith.subi %t24, %t42 : i32 loc(#loc509)
      memref.store %t43, %t11[%t39] : memref<8xi32>
      %t44 = arith.constant 7 : i32 loc(#loc510)
      %t45 = arith.index_cast %t44 : i32 to index
      %t46 = arith.constant 5 : i32 loc(#loc511)
      %t47 = arith.index_cast %t46 : i32 to index
      %t48 = memref.load %t11[%t47] : memref<8xi32> loc(#loc512)
      %t49 = arith.addi %t31, %t48 : i32 loc(#loc513)
      memref.store %t49, %t11[%t45] : memref<8xi32>
      %t50 = arith.constant 5 : i32 loc(#loc514)
      %t51 = arith.index_cast %t50 : i32 to index
      %t52 = arith.constant 5 : i32 loc(#loc515)
      %t53 = arith.index_cast %t52 : i32 to index
      %t54 = memref.load %t11[%t53] : memref<8xi32> loc(#loc516)
      %t55 = arith.subi %t31, %t54 : i32 loc(#loc517)
      memref.store %t55, %t11[%t51] : memref<8xi32>
      %t56 = arith.constant 3 : i32 loc(#loc518)
      %t57 = arith.index_cast %t56 : i32 to index
      %t58 = memref.load %t11[%t57] : memref<8xi32> loc(#loc519)
      %t59 = arith.constant 0 : i32
      %t60 = arith.constant 3 : i32 loc(#loc520)
      %t61 = arith.constant 0 : i32
      %t62 = arith.shrsi %t58, %t60 : i32 loc(#loc1)
      %t63 = arith.constant 7 : i32 loc(#loc521)
      %t64 = arith.constant 0 : i32
      %t65 = arith.shrsi %t58, %t63 : i32 loc(#loc1)
      %t66 = arith.subi %t62, %t65 : i32 loc(#loc522)
      %t67 = arith.subi %t58, %t66 : i32 loc(#loc523)
      %t68 = arith.constant 3 : i32 loc(#loc524)
      %t69 = arith.index_cast %t68 : i32 to index
      %t70 = memref.load %t11[%t69] : memref<8xi32> loc(#loc525)
      %t71 = arith.constant 0 : i32
      %t72 = arith.constant 3 : i32 loc(#loc526)
      %t73 = arith.constant 0 : i32
      %t74 = arith.shrsi %t70, %t72 : i32 loc(#loc1)
      %t75 = arith.constant 7 : i32 loc(#loc527)
      %t76 = arith.constant 0 : i32
      %t77 = arith.shrsi %t70, %t75 : i32 loc(#loc1)
      %t78 = arith.subi %t74, %t77 : i32 loc(#loc528)
      %t79 = arith.constant 11 : i32 loc(#loc529)
      %t80 = arith.constant 0 : i32
      %t81 = arith.shrsi %t70, %t79 : i32 loc(#loc1)
      %t82 = arith.subi %t78, %t81 : i32 loc(#loc530)
      %t83 = arith.constant 1 : i32 loc(#loc531)
      %t84 = arith.constant 0 : i32
      %t85 = arith.shrsi %t82, %t83 : i32 loc(#loc1)
      %t86 = arith.addi %t78, %t85 : i32 loc(#loc532)
      %t87 = arith.constant 5 : i32 loc(#loc533)
      %t88 = arith.index_cast %t87 : i32 to index
      %t89 = memref.load %t11[%t88] : memref<8xi32> loc(#loc534)
      %t90 = arith.constant 0 : i32
      %t91 = arith.constant 3 : i32 loc(#loc520)
      %t92 = arith.constant 0 : i32
      %t93 = arith.shrsi %t89, %t91 : i32 loc(#loc1)
      %t94 = arith.constant 7 : i32 loc(#loc521)
      %t95 = arith.constant 0 : i32
      %t96 = arith.shrsi %t89, %t94 : i32 loc(#loc1)
      %t97 = arith.subi %t93, %t96 : i32 loc(#loc522)
      %t98 = arith.subi %t89, %t97 : i32 loc(#loc523)
      %t99 = arith.constant 5 : i32 loc(#loc535)
      %t100 = arith.index_cast %t99 : i32 to index
      %t101 = memref.load %t11[%t100] : memref<8xi32> loc(#loc536)
      %t102 = arith.constant 0 : i32
      %t103 = arith.constant 3 : i32 loc(#loc526)
      %t104 = arith.constant 0 : i32
      %t105 = arith.shrsi %t101, %t103 : i32 loc(#loc1)
      %t106 = arith.constant 7 : i32 loc(#loc527)
      %t107 = arith.constant 0 : i32
      %t108 = arith.shrsi %t101, %t106 : i32 loc(#loc1)
      %t109 = arith.subi %t105, %t108 : i32 loc(#loc528)
      %t110 = arith.constant 11 : i32 loc(#loc529)
      %t111 = arith.constant 0 : i32
      %t112 = arith.shrsi %t101, %t110 : i32 loc(#loc1)
      %t113 = arith.subi %t109, %t112 : i32 loc(#loc530)
      %t114 = arith.constant 1 : i32 loc(#loc531)
      %t115 = arith.constant 0 : i32
      %t116 = arith.shrsi %t113, %t114 : i32 loc(#loc1)
      %t117 = arith.addi %t109, %t116 : i32 loc(#loc532)
      %t118 = arith.constant 3 : i32 loc(#loc537)
      %t119 = arith.index_cast %t118 : i32 to index
      %t120 = arith.subi %t67, %t117 : i32 loc(#loc538)
      memref.store %t120, %t11[%t119] : memref<8xi32>
      %t121 = arith.constant 5 : i32 loc(#loc539)
      %t122 = arith.index_cast %t121 : i32 to index
      %t123 = arith.addi %t98, %t86 : i32 loc(#loc540)
      memref.store %t123, %t11[%t122] : memref<8xi32>
      %t124 = arith.constant 1 : i32 loc(#loc541)
      %t125 = arith.index_cast %t124 : i32 to index
      %t126 = memref.load %t11[%t125] : memref<8xi32> loc(#loc542)
      %t127 = arith.constant 0 : i32
      %t128 = arith.constant 9 : i32 loc(#loc543)
      %t129 = arith.constant 0 : i32
      %t130 = arith.shrsi %t126, %t128 : i32 loc(#loc1)
      %t131 = arith.subi %t130, %t126 : i32 loc(#loc544)
      %t132 = arith.constant 2 : i32 loc(#loc545)
      %t133 = arith.constant 0 : i32
      %t134 = arith.shrsi %t131, %t132 : i32 loc(#loc1)
      %t135 = arith.subi %t134, %t131 : i32 loc(#loc546)
      %t136 = arith.constant 1 : i32 loc(#loc547)
      %t137 = arith.index_cast %t136 : i32 to index
      %t138 = memref.load %t11[%t137] : memref<8xi32> loc(#loc548)
      %t139 = arith.constant 0 : i32
      %t140 = arith.constant 1 : i32 loc(#loc549)
      %t141 = arith.constant 0 : i32
      %t142 = arith.shrsi %t138, %t140 : i32 loc(#loc1)
      %t143 = arith.constant 7 : i32 loc(#loc550)
      %t144 = arith.index_cast %t143 : i32 to index
      %t145 = memref.load %t11[%t144] : memref<8xi32> loc(#loc551)
      %t146 = arith.constant 0 : i32
      %t147 = arith.constant 9 : i32 loc(#loc543)
      %t148 = arith.constant 0 : i32
      %t149 = arith.shrsi %t145, %t147 : i32 loc(#loc1)
      %t150 = arith.subi %t149, %t145 : i32 loc(#loc544)
      %t151 = arith.constant 2 : i32 loc(#loc545)
      %t152 = arith.constant 0 : i32
      %t153 = arith.shrsi %t150, %t151 : i32 loc(#loc1)
      %t154 = arith.subi %t153, %t150 : i32 loc(#loc546)
      %t155 = arith.constant 7 : i32 loc(#loc552)
      %t156 = arith.index_cast %t155 : i32 to index
      %t157 = memref.load %t11[%t156] : memref<8xi32> loc(#loc553)
      %t158 = arith.constant 0 : i32
      %t159 = arith.constant 1 : i32 loc(#loc549)
      %t160 = arith.constant 0 : i32
      %t161 = arith.shrsi %t157, %t159 : i32 loc(#loc1)
      %t162 = arith.constant 1 : i32 loc(#loc554)
      %t163 = arith.index_cast %t162 : i32 to index
      %t164 = arith.addi %t135, %t161 : i32 loc(#loc555)
      memref.store %t164, %t11[%t163] : memref<8xi32>
      %t165 = arith.constant 7 : i32 loc(#loc556)
      %t166 = arith.index_cast %t165 : i32 to index
      %t167 = arith.subi %t154, %t142 : i32 loc(#loc557)
      memref.store %t167, %t11[%t166] : memref<8xi32>
      %t168 = arith.constant 2 : i32 loc(#loc558)
      %t169 = arith.index_cast %t168 : i32 to index
      %t170 = memref.load %t11[%t169] : memref<8xi32> loc(#loc559)
      %t171 = arith.constant 0 : i32
      %t172 = arith.constant 5 : i32 loc(#loc560)
      %t173 = arith.constant 0 : i32
      %t174 = arith.shrsi %t170, %t172 : i32 loc(#loc1)
      %t175 = arith.addi %t170, %t174 : i32 loc(#loc561)
      %t176 = arith.constant 2 : i32 loc(#loc562)
      %t177 = arith.constant 0 : i32
      %t178 = arith.shrsi %t175, %t176 : i32 loc(#loc1)
      %t179 = arith.constant 4 : i32 loc(#loc563)
      %t180 = arith.constant 0 : i32
      %t181 = arith.shrsi %t170, %t179 : i32 loc(#loc1)
      %t182 = arith.addi %t178, %t181 : i32 loc(#loc564)
      %t183 = arith.constant 2 : i32 loc(#loc565)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = memref.load %t11[%t184] : memref<8xi32> loc(#loc566)
      %t186 = arith.constant 0 : i32
      %t187 = arith.constant 5 : i32 loc(#loc567)
      %t188 = arith.constant 0 : i32
      %t189 = arith.shrsi %t185, %t187 : i32 loc(#loc1)
      %t190 = arith.addi %t185, %t189 : i32 loc(#loc568)
      %t191 = arith.constant 2 : i32 loc(#loc569)
      %t192 = arith.constant 0 : i32
      %t193 = arith.shrsi %t190, %t191 : i32 loc(#loc1)
      %t194 = arith.subi %t190, %t193 : i32 loc(#loc570)
      %t195 = arith.constant 6 : i32 loc(#loc571)
      %t196 = arith.index_cast %t195 : i32 to index
      %t197 = memref.load %t11[%t196] : memref<8xi32> loc(#loc572)
      %t198 = arith.constant 0 : i32
      %t199 = arith.constant 5 : i32 loc(#loc560)
      %t200 = arith.constant 0 : i32
      %t201 = arith.shrsi %t197, %t199 : i32 loc(#loc1)
      %t202 = arith.addi %t197, %t201 : i32 loc(#loc561)
      %t203 = arith.constant 2 : i32 loc(#loc562)
      %t204 = arith.constant 0 : i32
      %t205 = arith.shrsi %t202, %t203 : i32 loc(#loc1)
      %t206 = arith.constant 4 : i32 loc(#loc563)
      %t207 = arith.constant 0 : i32
      %t208 = arith.shrsi %t197, %t206 : i32 loc(#loc1)
      %t209 = arith.addi %t205, %t208 : i32 loc(#loc564)
      %t210 = arith.constant 6 : i32 loc(#loc573)
      %t211 = arith.index_cast %t210 : i32 to index
      %t212 = memref.load %t11[%t211] : memref<8xi32> loc(#loc574)
      %t213 = arith.constant 0 : i32
      %t214 = arith.constant 5 : i32 loc(#loc567)
      %t215 = arith.constant 0 : i32
      %t216 = arith.shrsi %t212, %t214 : i32 loc(#loc1)
      %t217 = arith.addi %t212, %t216 : i32 loc(#loc568)
      %t218 = arith.constant 2 : i32 loc(#loc569)
      %t219 = arith.constant 0 : i32
      %t220 = arith.shrsi %t217, %t218 : i32 loc(#loc1)
      %t221 = arith.subi %t217, %t220 : i32 loc(#loc570)
      %t222 = arith.constant 2 : i32 loc(#loc575)
      %t223 = arith.index_cast %t222 : i32 to index
      %t224 = arith.subi %t182, %t221 : i32 loc(#loc576)
      memref.store %t224, %t11[%t223] : memref<8xi32>
      %t225 = arith.constant 6 : i32 loc(#loc577)
      %t226 = arith.index_cast %t225 : i32 to index
      %t227 = arith.addi %t209, %t194 : i32 loc(#loc578)
      memref.store %t227, %t11[%t226] : memref<8xi32>
      %t228 = arith.constant 0 : i32 loc(#loc579)
      %t229 = arith.index_cast %t228 : i32 to index
      %t230 = memref.load %t11[%t229] : memref<8xi32> loc(#loc580)
      %t231 = arith.constant 4 : i32 loc(#loc581)
      %t232 = arith.index_cast %t231 : i32 to index
      %t233 = memref.load %t11[%t232] : memref<8xi32> loc(#loc582)
      %t234 = arith.addi %t230, %t233 : i32 loc(#loc580)
      %t235 = arith.constant 0 : i32 loc(#loc583)
      %t236 = arith.index_cast %t235 : i32 to index
      %t237 = memref.load %t11[%t236] : memref<8xi32> loc(#loc584)
      %t238 = arith.constant 4 : i32 loc(#loc585)
      %t239 = arith.index_cast %t238 : i32 to index
      %t240 = memref.load %t11[%t239] : memref<8xi32> loc(#loc586)
      %t241 = arith.subi %t237, %t240 : i32 loc(#loc584)
      %t242 = arith.constant 0 : i32 loc(#loc587)
      %t243 = arith.index_cast %t242 : i32 to index
      %t244 = arith.constant 6 : i32 loc(#loc588)
      %t245 = arith.index_cast %t244 : i32 to index
      %t246 = memref.load %t11[%t245] : memref<8xi32> loc(#loc589)
      %t247 = arith.addi %t234, %t246 : i32 loc(#loc590)
      memref.store %t247, %t11[%t243] : memref<8xi32>
      %t248 = arith.constant 6 : i32 loc(#loc591)
      %t249 = arith.index_cast %t248 : i32 to index
      %t250 = arith.constant 6 : i32 loc(#loc592)
      %t251 = arith.index_cast %t250 : i32 to index
      %t252 = memref.load %t11[%t251] : memref<8xi32> loc(#loc593)
      %t253 = arith.subi %t234, %t252 : i32 loc(#loc594)
      memref.store %t253, %t11[%t249] : memref<8xi32>
      %t254 = arith.constant 4 : i32 loc(#loc595)
      %t255 = arith.index_cast %t254 : i32 to index
      %t256 = arith.constant 2 : i32 loc(#loc596)
      %t257 = arith.index_cast %t256 : i32 to index
      %t258 = memref.load %t11[%t257] : memref<8xi32> loc(#loc597)
      %t259 = arith.addi %t241, %t258 : i32 loc(#loc598)
      memref.store %t259, %t11[%t255] : memref<8xi32>
      %t260 = arith.constant 2 : i32 loc(#loc599)
      %t261 = arith.index_cast %t260 : i32 to index
      %t262 = arith.constant 2 : i32 loc(#loc600)
      %t263 = arith.index_cast %t262 : i32 to index
      %t264 = memref.load %t11[%t263] : memref<8xi32> loc(#loc601)
      %t265 = arith.subi %t241, %t264 : i32 loc(#loc602)
      memref.store %t265, %t11[%t261] : memref<8xi32>
      %t266 = arith.constant 0 : i32 loc(#loc603)
      %t267 = arith.index_cast %t266 : i32 to index
      %t268 = memref.load %t11[%t267] : memref<8xi32> loc(#loc604)
      %t269 = arith.constant 1 : i32 loc(#loc605)
      %t270 = arith.index_cast %t269 : i32 to index
      %t271 = memref.load %t11[%t270] : memref<8xi32> loc(#loc606)
      %t272 = arith.addi %t268, %t271 : i32 loc(#loc604)
      %t273 = arith.constant 0 : index
      memref.store %t272, %t10[%t273] : memref<8xi32>
      %t274 = arith.constant 4 : i32 loc(#loc607)
      %t275 = arith.index_cast %t274 : i32 to index
      %t276 = memref.load %t11[%t275] : memref<8xi32> loc(#loc608)
      %t277 = arith.constant 5 : i32 loc(#loc609)
      %t278 = arith.index_cast %t277 : i32 to index
      %t279 = memref.load %t11[%t278] : memref<8xi32> loc(#loc610)
      %t280 = arith.addi %t276, %t279 : i32 loc(#loc608)
      %t281 = arith.constant 1 : index
      memref.store %t280, %t10[%t281] : memref<8xi32>
      %t282 = arith.constant 2 : i32 loc(#loc611)
      %t283 = arith.index_cast %t282 : i32 to index
      %t284 = memref.load %t11[%t283] : memref<8xi32> loc(#loc612)
      %t285 = arith.constant 3 : i32 loc(#loc613)
      %t286 = arith.index_cast %t285 : i32 to index
      %t287 = memref.load %t11[%t286] : memref<8xi32> loc(#loc614)
      %t288 = arith.addi %t284, %t287 : i32 loc(#loc612)
      %t289 = arith.constant 2 : index
      memref.store %t288, %t10[%t289] : memref<8xi32>
      %t290 = arith.constant 6 : i32 loc(#loc615)
      %t291 = arith.index_cast %t290 : i32 to index
      %t292 = memref.load %t11[%t291] : memref<8xi32> loc(#loc616)
      %t293 = arith.constant 7 : i32 loc(#loc617)
      %t294 = arith.index_cast %t293 : i32 to index
      %t295 = memref.load %t11[%t294] : memref<8xi32> loc(#loc618)
      %t296 = arith.addi %t292, %t295 : i32 loc(#loc616)
      %t297 = arith.constant 3 : index
      memref.store %t296, %t10[%t297] : memref<8xi32>
      %t298 = arith.constant 6 : i32 loc(#loc619)
      %t299 = arith.index_cast %t298 : i32 to index
      %t300 = memref.load %t11[%t299] : memref<8xi32> loc(#loc620)
      %t301 = arith.constant 7 : i32 loc(#loc621)
      %t302 = arith.index_cast %t301 : i32 to index
      %t303 = memref.load %t11[%t302] : memref<8xi32> loc(#loc622)
      %t304 = arith.subi %t300, %t303 : i32 loc(#loc620)
      %t305 = arith.constant 4 : index
      memref.store %t304, %t10[%t305] : memref<8xi32>
      %t306 = arith.constant 2 : i32 loc(#loc623)
      %t307 = arith.index_cast %t306 : i32 to index
      %t308 = memref.load %t11[%t307] : memref<8xi32> loc(#loc624)
      %t309 = arith.constant 3 : i32 loc(#loc625)
      %t310 = arith.index_cast %t309 : i32 to index
      %t311 = memref.load %t11[%t310] : memref<8xi32> loc(#loc626)
      %t312 = arith.subi %t308, %t311 : i32 loc(#loc624)
      %t313 = arith.constant 5 : index
      memref.store %t312, %t10[%t313] : memref<8xi32>
      %t314 = arith.constant 4 : i32 loc(#loc627)
      %t315 = arith.index_cast %t314 : i32 to index
      %t316 = memref.load %t11[%t315] : memref<8xi32> loc(#loc628)
      %t317 = arith.constant 5 : i32 loc(#loc629)
      %t318 = arith.index_cast %t317 : i32 to index
      %t319 = memref.load %t11[%t318] : memref<8xi32> loc(#loc630)
      %t320 = arith.subi %t316, %t319 : i32 loc(#loc628)
      %t321 = arith.constant 6 : index
      memref.store %t320, %t10[%t321] : memref<8xi32>
      %t322 = arith.constant 0 : i32 loc(#loc631)
      %t323 = arith.index_cast %t322 : i32 to index
      %t324 = memref.load %t11[%t323] : memref<8xi32> loc(#loc632)
      %t325 = arith.constant 1 : i32 loc(#loc633)
      %t326 = arith.index_cast %t325 : i32 to index
      %t327 = memref.load %t11[%t326] : memref<8xi32> loc(#loc634)
      %t328 = arith.subi %t324, %t327 : i32 loc(#loc632)
      %t329 = arith.constant 7 : index
      memref.store %t328, %t10[%t329] : memref<8xi32>
      %t330 = arith.constant 8 : i32 loc(#loc635)
      %t331 = arith.index_cast %t330 : i32 to index
      %t332 = arith.constant 0 : index
      %t333 = arith.constant 1 : index
      scf.for %t334 = %t332 to %t331 step %t333 {
        %t335 = memref.load %t10[%t334] : memref<8xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t335: i32)
        scf.yield
      }
    } loc(#loc493)
  } loc(#loc636)
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_1(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc637)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc639)
      %t11 = arith.constant 7 : i32 loc(#loc640)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 0 : i32 loc(#loc641)
      %t17 = arith.constant 7 : i32 loc(#loc642)
      %t18 = arith.index_cast %t16 : i32 to index
      %t19 = arith.index_cast %t17 : i32 to index
      %t20 = arith.constant 1 : index
      %t21 = arith.addi %t19, %t20 : index
      %t22 = arith.constant 1 : index
      scf.for %t23 = %t12 to %t15 step %t22 {
        %t24 = arith.index_cast %t23 : index to i32
        scf.for %t25 = %t18 to %t21 step %t22 {
          %t26 = arith.index_cast %t25 : index to i32
          %t27 = arith.constant 8 : i32 loc(#loc643)
          %t29 = arith.extsi %t27 : i32 to i64
          %t30 = arith.extsi %t26 : i32 to i64
          %t28 = arith.muli %t29, %t30 : i64 loc(#loc643)
          %t31 = arith.extsi %t24 : i32 to i64
          %t32 = arith.addi %t28, %t31 : i64 loc(#loc643)
          %t33 = arith.index_cast %t32 : i64 to index
          %t34 = memref.load %t4[%t33] : memref<64xi32> loc(#loc644)
          fifo.push(%OUT: !fifo.input_port<i32>, %t34: i32)
          scf.yield
        }
        scf.yield
      }
    } loc(#loc638)
  } loc(#loc645)
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_1(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc646)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "shift" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc648)
      %t11 = arith.constant 63 : i32 loc(#loc649)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 1 : index
      scf.for %t17 = %t12 to %t15 step %t16 {
        %t18 = arith.index_cast %t17 : index to i32
        %t19 = arith.index_cast %t18 : i32 to index
        %t20 = memref.load %t4[%t19] : memref<64xi32> loc(#loc650)
        %t21 = arith.constant 13 : i32 loc(#loc651)
        %t22 = arith.constant 0 : i32
        %t23 = arith.shrsi %t20, %t21 : i32 loc(#loc1)
        %t24 = arith.constant 128 : i32 loc(#loc652)
        %t25 = arith.addi %t23, %t24 : i32 loc(#loc653)
        %t26 = arith.constant 0 : i32 loc(#loc654)
        %t27 = arith.constant 255 : i32 loc(#loc655)
        %t28 = arith.constant 0 : i8
        %t29 = arith.cmpi sgt, %t25, %t27 : i32 loc(#loc656)
        %t32 = scf.if %t29 -> i32 {
          scf.yield %t27 : i32
        } else {
          %t30 = arith.cmpi slt, %t25, %t26 : i32 loc(#loc657)
          %t31 = scf.if %t30 -> i32 {
            scf.yield %t26 : i32
          } else {
            scf.yield %t25 : i32
          }
          scf.yield %t31 : i32
        }
        %t33 = arith.trunci %t32 : i32 to i8
        fifo.push(%OUT: !fifo.input_port<i8>, %t33: i8)
        scf.yield
      }
    } loc(#loc647)
  } loc(#loc658)
  cal.actor @jpeg_decoder_parallel_idct__Scale__v__index_2(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i13>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t2 = arith.constant 1024 : i32 loc(#loc468)
    cal.set(%t1: !cal.state_ref<i32>, %t2: i32)
    %t3 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t4 = arith.constant 1138 : i32 loc(#loc469)
    cal.set(%t3: !cal.state_ref<i32>, %t4: i32)
    %t5 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t6 = arith.constant 1730 : i32 loc(#loc470)
    cal.set(%t5: !cal.state_ref<i32>, %t6: i32)
    %t7 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t8 = arith.constant 1609 : i32 loc(#loc471)
    cal.set(%t7: !cal.state_ref<i32>, %t8: i32)
    %t9 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t10 = arith.constant 1264 : i32 loc(#loc472)
    cal.set(%t9: !cal.state_ref<i32>, %t10: i32)
    %t11 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t12 = arith.constant 1922 : i32 loc(#loc473)
    cal.set(%t11: !cal.state_ref<i32>, %t12: i32)
    %t13 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t14 = arith.constant 1788 : i32 loc(#loc474)
    cal.set(%t13: !cal.state_ref<i32>, %t14: i32)
    %t15 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t16 = arith.constant 2923 : i32 loc(#loc475)
    cal.set(%t15: !cal.state_ref<i32>, %t16: i32)
    %t17 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t18 = arith.constant 2718 : i32 loc(#loc476)
    cal.set(%t17: !cal.state_ref<i32>, %t18: i32)
    %t19 = cal.create_state_var<i32> : !cal.state_ref<i32>
    %t20 = arith.constant 2528 : i32 loc(#loc477)
    cal.set(%t19: !cal.state_ref<i32>, %t20: i32)
    %t21 = cal.create_state_var<memref<64xi16>> : !cal.state_ref<memref<64xi16>>
    %t22 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
    %t23 = memref.get_global @__cmr_5 : memref<64xi16>
    memref.copy %t23, %t22 : memref<64xi16> to memref<64xi16>
    %t24 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t25 = arith.constant 0 : i32 loc(#loc478)
    %t26 = arith.extsi %t25 : i32 to i64
    cal.set(%t24: !cal.state_ref<i64>, %t26: i64)
    cal.action "scale" priority=0 {
      %t27 = memref.alloca() : memref<64xi32>
      %t28 = memref.alloca() : memref<64xi13>
      %t29 = arith.constant 64 : index
      %t30 = arith.constant 0 : index
      %t31 = arith.constant 1 : index
      scf.for %t32 = %t30 to %t29 step %t31 {
        %t33 = fifo.pop(%IN: !fifo.output_port<i13> ) : i13
        memref.store %t33, %t28[%t32] : memref<64xi13>
        scf.yield
      }
      %t34 = arith.constant 0 : i32 loc(#loc480)
      %t35 = arith.constant 63 : i32 loc(#loc481)
      %t36 = arith.index_cast %t34 : i32 to index
      %t37 = arith.index_cast %t35 : i32 to index
      %t38 = arith.constant 1 : index
      %t39 = arith.addi %t37, %t38 : index
      %t40 = arith.constant 1 : index
      scf.for %t41 = %t36 to %t39 step %t40 {
        %t42 = arith.index_cast %t41 : index to i32
        %t43 = arith.index_cast %t42 : i32 to index
        %t44 = memref.load %t28[%t43] : memref<64xi13> loc(#loc482)
        %t45 = cal.get(%t21: !cal.state_ref<memref<64xi16>>) : memref<64xi16>
        %t46 = arith.index_cast %t42 : i32 to index
        %t47 = memref.load %t45[%t46] : memref<64xi16> loc(#loc483)
        %t48 = arith.extsi %t44 : i13 to i16
        %t50 = arith.extsi %t48 : i16 to i32
        %t51 = arith.extsi %t47 : i16 to i32
        %t49 = arith.muli %t50, %t51 : i32 loc(#loc482)
        %t52 = arith.subi %t41, %t36 : index
        memref.store %t49, %t27[%t52] : memref<64xi32>
        scf.yield
      }
      %t53 = arith.constant 0 : i32 loc(#loc484)
      %t54 = arith.index_cast %t53 : i32 to index
      %t55 = arith.constant 0 : i32 loc(#loc485)
      %t56 = arith.index_cast %t55 : i32 to index
      %t57 = memref.load %t27[%t56] : memref<64xi32> loc(#loc486)
      %t58 = arith.constant 4096 : i32 loc(#loc487)
      %t59 = arith.addi %t57, %t58 : i32 loc(#loc486)
      memref.store %t59, %t27[%t54] : memref<64xi32>
      %t60 = cal.get(%t24: !cal.state_ref<i64>) : i64
      %t61 = arith.constant 64 : i32 loc(#loc488)
      %t62 = arith.extsi %t61 : i32 to i64
      %t63 = arith.addi %t60, %t62 : i64 loc(#loc489)
      cal.set(%t24: !cal.state_ref<i64>, %t63: i64)
      %t64 = arith.constant 64 : i32 loc(#loc490)
      %t65 = arith.index_cast %t64 : i32 to index
      %t66 = arith.constant 0 : index
      %t67 = arith.constant 1 : index
      scf.for %t68 = %t66 to %t65 step %t67 {
        %t69 = memref.load %t27[%t68] : memref<64xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t69: i32)
        scf.yield
      }
    } loc(#loc479)
  } loc(#loc491)
  cal.actor @jpeg_decoder_parallel_idct__Scaled_1d_idct__v__index_2(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc492)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = arith.constant 0 : i32
      %t5 = arith.constant 0 : i32
      %t6 = arith.constant 0 : i32
      %t7 = arith.constant 0 : i32
      %t8 = arith.constant 0 : i32
      %t9 = arith.constant 0 : i32
      %t10 = memref.alloca() : memref<8xi32>
      %t11 = memref.alloca() : memref<8xi32>
      %t12 = memref.alloca() : memref<8xi32>
      %t13 = arith.constant 8 : index
      %t14 = arith.constant 0 : index
      %t15 = arith.constant 1 : index
      scf.for %t16 = %t14 to %t13 step %t15 {
        %t17 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t17, %t12[%t16] : memref<8xi32>
        scf.yield
      }
      memref.copy %t12, %t11 : memref<8xi32> to memref<8xi32>
      %t18 = arith.constant 1 : i32 loc(#loc494)
      %t19 = arith.index_cast %t18 : i32 to index
      %t20 = memref.load %t11[%t19] : memref<8xi32> loc(#loc495)
      %t21 = arith.constant 7 : i32 loc(#loc496)
      %t22 = arith.index_cast %t21 : i32 to index
      %t23 = memref.load %t11[%t22] : memref<8xi32> loc(#loc497)
      %t24 = arith.addi %t20, %t23 : i32 loc(#loc495)
      %t25 = arith.constant 1 : i32 loc(#loc498)
      %t26 = arith.index_cast %t25 : i32 to index
      %t27 = memref.load %t11[%t26] : memref<8xi32> loc(#loc499)
      %t28 = arith.constant 7 : i32 loc(#loc500)
      %t29 = arith.index_cast %t28 : i32 to index
      %t30 = memref.load %t11[%t29] : memref<8xi32> loc(#loc501)
      %t31 = arith.subi %t27, %t30 : i32 loc(#loc499)
      %t32 = arith.constant 1 : i32 loc(#loc502)
      %t33 = arith.index_cast %t32 : i32 to index
      %t34 = arith.constant 3 : i32 loc(#loc503)
      %t35 = arith.index_cast %t34 : i32 to index
      %t36 = memref.load %t11[%t35] : memref<8xi32> loc(#loc504)
      %t37 = arith.addi %t24, %t36 : i32 loc(#loc505)
      memref.store %t37, %t11[%t33] : memref<8xi32>
      %t38 = arith.constant 3 : i32 loc(#loc506)
      %t39 = arith.index_cast %t38 : i32 to index
      %t40 = arith.constant 3 : i32 loc(#loc507)
      %t41 = arith.index_cast %t40 : i32 to index
      %t42 = memref.load %t11[%t41] : memref<8xi32> loc(#loc508)
      %t43 = arith.subi %t24, %t42 : i32 loc(#loc509)
      memref.store %t43, %t11[%t39] : memref<8xi32>
      %t44 = arith.constant 7 : i32 loc(#loc510)
      %t45 = arith.index_cast %t44 : i32 to index
      %t46 = arith.constant 5 : i32 loc(#loc511)
      %t47 = arith.index_cast %t46 : i32 to index
      %t48 = memref.load %t11[%t47] : memref<8xi32> loc(#loc512)
      %t49 = arith.addi %t31, %t48 : i32 loc(#loc513)
      memref.store %t49, %t11[%t45] : memref<8xi32>
      %t50 = arith.constant 5 : i32 loc(#loc514)
      %t51 = arith.index_cast %t50 : i32 to index
      %t52 = arith.constant 5 : i32 loc(#loc515)
      %t53 = arith.index_cast %t52 : i32 to index
      %t54 = memref.load %t11[%t53] : memref<8xi32> loc(#loc516)
      %t55 = arith.subi %t31, %t54 : i32 loc(#loc517)
      memref.store %t55, %t11[%t51] : memref<8xi32>
      %t56 = arith.constant 3 : i32 loc(#loc518)
      %t57 = arith.index_cast %t56 : i32 to index
      %t58 = memref.load %t11[%t57] : memref<8xi32> loc(#loc519)
      %t59 = arith.constant 0 : i32
      %t60 = arith.constant 3 : i32 loc(#loc520)
      %t61 = arith.constant 0 : i32
      %t62 = arith.shrsi %t58, %t60 : i32 loc(#loc1)
      %t63 = arith.constant 7 : i32 loc(#loc521)
      %t64 = arith.constant 0 : i32
      %t65 = arith.shrsi %t58, %t63 : i32 loc(#loc1)
      %t66 = arith.subi %t62, %t65 : i32 loc(#loc522)
      %t67 = arith.subi %t58, %t66 : i32 loc(#loc523)
      %t68 = arith.constant 3 : i32 loc(#loc524)
      %t69 = arith.index_cast %t68 : i32 to index
      %t70 = memref.load %t11[%t69] : memref<8xi32> loc(#loc525)
      %t71 = arith.constant 0 : i32
      %t72 = arith.constant 3 : i32 loc(#loc526)
      %t73 = arith.constant 0 : i32
      %t74 = arith.shrsi %t70, %t72 : i32 loc(#loc1)
      %t75 = arith.constant 7 : i32 loc(#loc527)
      %t76 = arith.constant 0 : i32
      %t77 = arith.shrsi %t70, %t75 : i32 loc(#loc1)
      %t78 = arith.subi %t74, %t77 : i32 loc(#loc528)
      %t79 = arith.constant 11 : i32 loc(#loc529)
      %t80 = arith.constant 0 : i32
      %t81 = arith.shrsi %t70, %t79 : i32 loc(#loc1)
      %t82 = arith.subi %t78, %t81 : i32 loc(#loc530)
      %t83 = arith.constant 1 : i32 loc(#loc531)
      %t84 = arith.constant 0 : i32
      %t85 = arith.shrsi %t82, %t83 : i32 loc(#loc1)
      %t86 = arith.addi %t78, %t85 : i32 loc(#loc532)
      %t87 = arith.constant 5 : i32 loc(#loc533)
      %t88 = arith.index_cast %t87 : i32 to index
      %t89 = memref.load %t11[%t88] : memref<8xi32> loc(#loc534)
      %t90 = arith.constant 0 : i32
      %t91 = arith.constant 3 : i32 loc(#loc520)
      %t92 = arith.constant 0 : i32
      %t93 = arith.shrsi %t89, %t91 : i32 loc(#loc1)
      %t94 = arith.constant 7 : i32 loc(#loc521)
      %t95 = arith.constant 0 : i32
      %t96 = arith.shrsi %t89, %t94 : i32 loc(#loc1)
      %t97 = arith.subi %t93, %t96 : i32 loc(#loc522)
      %t98 = arith.subi %t89, %t97 : i32 loc(#loc523)
      %t99 = arith.constant 5 : i32 loc(#loc535)
      %t100 = arith.index_cast %t99 : i32 to index
      %t101 = memref.load %t11[%t100] : memref<8xi32> loc(#loc536)
      %t102 = arith.constant 0 : i32
      %t103 = arith.constant 3 : i32 loc(#loc526)
      %t104 = arith.constant 0 : i32
      %t105 = arith.shrsi %t101, %t103 : i32 loc(#loc1)
      %t106 = arith.constant 7 : i32 loc(#loc527)
      %t107 = arith.constant 0 : i32
      %t108 = arith.shrsi %t101, %t106 : i32 loc(#loc1)
      %t109 = arith.subi %t105, %t108 : i32 loc(#loc528)
      %t110 = arith.constant 11 : i32 loc(#loc529)
      %t111 = arith.constant 0 : i32
      %t112 = arith.shrsi %t101, %t110 : i32 loc(#loc1)
      %t113 = arith.subi %t109, %t112 : i32 loc(#loc530)
      %t114 = arith.constant 1 : i32 loc(#loc531)
      %t115 = arith.constant 0 : i32
      %t116 = arith.shrsi %t113, %t114 : i32 loc(#loc1)
      %t117 = arith.addi %t109, %t116 : i32 loc(#loc532)
      %t118 = arith.constant 3 : i32 loc(#loc537)
      %t119 = arith.index_cast %t118 : i32 to index
      %t120 = arith.subi %t67, %t117 : i32 loc(#loc538)
      memref.store %t120, %t11[%t119] : memref<8xi32>
      %t121 = arith.constant 5 : i32 loc(#loc539)
      %t122 = arith.index_cast %t121 : i32 to index
      %t123 = arith.addi %t98, %t86 : i32 loc(#loc540)
      memref.store %t123, %t11[%t122] : memref<8xi32>
      %t124 = arith.constant 1 : i32 loc(#loc541)
      %t125 = arith.index_cast %t124 : i32 to index
      %t126 = memref.load %t11[%t125] : memref<8xi32> loc(#loc542)
      %t127 = arith.constant 0 : i32
      %t128 = arith.constant 9 : i32 loc(#loc543)
      %t129 = arith.constant 0 : i32
      %t130 = arith.shrsi %t126, %t128 : i32 loc(#loc1)
      %t131 = arith.subi %t130, %t126 : i32 loc(#loc544)
      %t132 = arith.constant 2 : i32 loc(#loc545)
      %t133 = arith.constant 0 : i32
      %t134 = arith.shrsi %t131, %t132 : i32 loc(#loc1)
      %t135 = arith.subi %t134, %t131 : i32 loc(#loc546)
      %t136 = arith.constant 1 : i32 loc(#loc547)
      %t137 = arith.index_cast %t136 : i32 to index
      %t138 = memref.load %t11[%t137] : memref<8xi32> loc(#loc548)
      %t139 = arith.constant 0 : i32
      %t140 = arith.constant 1 : i32 loc(#loc549)
      %t141 = arith.constant 0 : i32
      %t142 = arith.shrsi %t138, %t140 : i32 loc(#loc1)
      %t143 = arith.constant 7 : i32 loc(#loc550)
      %t144 = arith.index_cast %t143 : i32 to index
      %t145 = memref.load %t11[%t144] : memref<8xi32> loc(#loc551)
      %t146 = arith.constant 0 : i32
      %t147 = arith.constant 9 : i32 loc(#loc543)
      %t148 = arith.constant 0 : i32
      %t149 = arith.shrsi %t145, %t147 : i32 loc(#loc1)
      %t150 = arith.subi %t149, %t145 : i32 loc(#loc544)
      %t151 = arith.constant 2 : i32 loc(#loc545)
      %t152 = arith.constant 0 : i32
      %t153 = arith.shrsi %t150, %t151 : i32 loc(#loc1)
      %t154 = arith.subi %t153, %t150 : i32 loc(#loc546)
      %t155 = arith.constant 7 : i32 loc(#loc552)
      %t156 = arith.index_cast %t155 : i32 to index
      %t157 = memref.load %t11[%t156] : memref<8xi32> loc(#loc553)
      %t158 = arith.constant 0 : i32
      %t159 = arith.constant 1 : i32 loc(#loc549)
      %t160 = arith.constant 0 : i32
      %t161 = arith.shrsi %t157, %t159 : i32 loc(#loc1)
      %t162 = arith.constant 1 : i32 loc(#loc554)
      %t163 = arith.index_cast %t162 : i32 to index
      %t164 = arith.addi %t135, %t161 : i32 loc(#loc555)
      memref.store %t164, %t11[%t163] : memref<8xi32>
      %t165 = arith.constant 7 : i32 loc(#loc556)
      %t166 = arith.index_cast %t165 : i32 to index
      %t167 = arith.subi %t154, %t142 : i32 loc(#loc557)
      memref.store %t167, %t11[%t166] : memref<8xi32>
      %t168 = arith.constant 2 : i32 loc(#loc558)
      %t169 = arith.index_cast %t168 : i32 to index
      %t170 = memref.load %t11[%t169] : memref<8xi32> loc(#loc559)
      %t171 = arith.constant 0 : i32
      %t172 = arith.constant 5 : i32 loc(#loc560)
      %t173 = arith.constant 0 : i32
      %t174 = arith.shrsi %t170, %t172 : i32 loc(#loc1)
      %t175 = arith.addi %t170, %t174 : i32 loc(#loc561)
      %t176 = arith.constant 2 : i32 loc(#loc562)
      %t177 = arith.constant 0 : i32
      %t178 = arith.shrsi %t175, %t176 : i32 loc(#loc1)
      %t179 = arith.constant 4 : i32 loc(#loc563)
      %t180 = arith.constant 0 : i32
      %t181 = arith.shrsi %t170, %t179 : i32 loc(#loc1)
      %t182 = arith.addi %t178, %t181 : i32 loc(#loc564)
      %t183 = arith.constant 2 : i32 loc(#loc565)
      %t184 = arith.index_cast %t183 : i32 to index
      %t185 = memref.load %t11[%t184] : memref<8xi32> loc(#loc566)
      %t186 = arith.constant 0 : i32
      %t187 = arith.constant 5 : i32 loc(#loc567)
      %t188 = arith.constant 0 : i32
      %t189 = arith.shrsi %t185, %t187 : i32 loc(#loc1)
      %t190 = arith.addi %t185, %t189 : i32 loc(#loc568)
      %t191 = arith.constant 2 : i32 loc(#loc569)
      %t192 = arith.constant 0 : i32
      %t193 = arith.shrsi %t190, %t191 : i32 loc(#loc1)
      %t194 = arith.subi %t190, %t193 : i32 loc(#loc570)
      %t195 = arith.constant 6 : i32 loc(#loc571)
      %t196 = arith.index_cast %t195 : i32 to index
      %t197 = memref.load %t11[%t196] : memref<8xi32> loc(#loc572)
      %t198 = arith.constant 0 : i32
      %t199 = arith.constant 5 : i32 loc(#loc560)
      %t200 = arith.constant 0 : i32
      %t201 = arith.shrsi %t197, %t199 : i32 loc(#loc1)
      %t202 = arith.addi %t197, %t201 : i32 loc(#loc561)
      %t203 = arith.constant 2 : i32 loc(#loc562)
      %t204 = arith.constant 0 : i32
      %t205 = arith.shrsi %t202, %t203 : i32 loc(#loc1)
      %t206 = arith.constant 4 : i32 loc(#loc563)
      %t207 = arith.constant 0 : i32
      %t208 = arith.shrsi %t197, %t206 : i32 loc(#loc1)
      %t209 = arith.addi %t205, %t208 : i32 loc(#loc564)
      %t210 = arith.constant 6 : i32 loc(#loc573)
      %t211 = arith.index_cast %t210 : i32 to index
      %t212 = memref.load %t11[%t211] : memref<8xi32> loc(#loc574)
      %t213 = arith.constant 0 : i32
      %t214 = arith.constant 5 : i32 loc(#loc567)
      %t215 = arith.constant 0 : i32
      %t216 = arith.shrsi %t212, %t214 : i32 loc(#loc1)
      %t217 = arith.addi %t212, %t216 : i32 loc(#loc568)
      %t218 = arith.constant 2 : i32 loc(#loc569)
      %t219 = arith.constant 0 : i32
      %t220 = arith.shrsi %t217, %t218 : i32 loc(#loc1)
      %t221 = arith.subi %t217, %t220 : i32 loc(#loc570)
      %t222 = arith.constant 2 : i32 loc(#loc575)
      %t223 = arith.index_cast %t222 : i32 to index
      %t224 = arith.subi %t182, %t221 : i32 loc(#loc576)
      memref.store %t224, %t11[%t223] : memref<8xi32>
      %t225 = arith.constant 6 : i32 loc(#loc577)
      %t226 = arith.index_cast %t225 : i32 to index
      %t227 = arith.addi %t209, %t194 : i32 loc(#loc578)
      memref.store %t227, %t11[%t226] : memref<8xi32>
      %t228 = arith.constant 0 : i32 loc(#loc579)
      %t229 = arith.index_cast %t228 : i32 to index
      %t230 = memref.load %t11[%t229] : memref<8xi32> loc(#loc580)
      %t231 = arith.constant 4 : i32 loc(#loc581)
      %t232 = arith.index_cast %t231 : i32 to index
      %t233 = memref.load %t11[%t232] : memref<8xi32> loc(#loc582)
      %t234 = arith.addi %t230, %t233 : i32 loc(#loc580)
      %t235 = arith.constant 0 : i32 loc(#loc583)
      %t236 = arith.index_cast %t235 : i32 to index
      %t237 = memref.load %t11[%t236] : memref<8xi32> loc(#loc584)
      %t238 = arith.constant 4 : i32 loc(#loc585)
      %t239 = arith.index_cast %t238 : i32 to index
      %t240 = memref.load %t11[%t239] : memref<8xi32> loc(#loc586)
      %t241 = arith.subi %t237, %t240 : i32 loc(#loc584)
      %t242 = arith.constant 0 : i32 loc(#loc587)
      %t243 = arith.index_cast %t242 : i32 to index
      %t244 = arith.constant 6 : i32 loc(#loc588)
      %t245 = arith.index_cast %t244 : i32 to index
      %t246 = memref.load %t11[%t245] : memref<8xi32> loc(#loc589)
      %t247 = arith.addi %t234, %t246 : i32 loc(#loc590)
      memref.store %t247, %t11[%t243] : memref<8xi32>
      %t248 = arith.constant 6 : i32 loc(#loc591)
      %t249 = arith.index_cast %t248 : i32 to index
      %t250 = arith.constant 6 : i32 loc(#loc592)
      %t251 = arith.index_cast %t250 : i32 to index
      %t252 = memref.load %t11[%t251] : memref<8xi32> loc(#loc593)
      %t253 = arith.subi %t234, %t252 : i32 loc(#loc594)
      memref.store %t253, %t11[%t249] : memref<8xi32>
      %t254 = arith.constant 4 : i32 loc(#loc595)
      %t255 = arith.index_cast %t254 : i32 to index
      %t256 = arith.constant 2 : i32 loc(#loc596)
      %t257 = arith.index_cast %t256 : i32 to index
      %t258 = memref.load %t11[%t257] : memref<8xi32> loc(#loc597)
      %t259 = arith.addi %t241, %t258 : i32 loc(#loc598)
      memref.store %t259, %t11[%t255] : memref<8xi32>
      %t260 = arith.constant 2 : i32 loc(#loc599)
      %t261 = arith.index_cast %t260 : i32 to index
      %t262 = arith.constant 2 : i32 loc(#loc600)
      %t263 = arith.index_cast %t262 : i32 to index
      %t264 = memref.load %t11[%t263] : memref<8xi32> loc(#loc601)
      %t265 = arith.subi %t241, %t264 : i32 loc(#loc602)
      memref.store %t265, %t11[%t261] : memref<8xi32>
      %t266 = arith.constant 0 : i32 loc(#loc603)
      %t267 = arith.index_cast %t266 : i32 to index
      %t268 = memref.load %t11[%t267] : memref<8xi32> loc(#loc604)
      %t269 = arith.constant 1 : i32 loc(#loc605)
      %t270 = arith.index_cast %t269 : i32 to index
      %t271 = memref.load %t11[%t270] : memref<8xi32> loc(#loc606)
      %t272 = arith.addi %t268, %t271 : i32 loc(#loc604)
      %t273 = arith.constant 0 : index
      memref.store %t272, %t10[%t273] : memref<8xi32>
      %t274 = arith.constant 4 : i32 loc(#loc607)
      %t275 = arith.index_cast %t274 : i32 to index
      %t276 = memref.load %t11[%t275] : memref<8xi32> loc(#loc608)
      %t277 = arith.constant 5 : i32 loc(#loc609)
      %t278 = arith.index_cast %t277 : i32 to index
      %t279 = memref.load %t11[%t278] : memref<8xi32> loc(#loc610)
      %t280 = arith.addi %t276, %t279 : i32 loc(#loc608)
      %t281 = arith.constant 1 : index
      memref.store %t280, %t10[%t281] : memref<8xi32>
      %t282 = arith.constant 2 : i32 loc(#loc611)
      %t283 = arith.index_cast %t282 : i32 to index
      %t284 = memref.load %t11[%t283] : memref<8xi32> loc(#loc612)
      %t285 = arith.constant 3 : i32 loc(#loc613)
      %t286 = arith.index_cast %t285 : i32 to index
      %t287 = memref.load %t11[%t286] : memref<8xi32> loc(#loc614)
      %t288 = arith.addi %t284, %t287 : i32 loc(#loc612)
      %t289 = arith.constant 2 : index
      memref.store %t288, %t10[%t289] : memref<8xi32>
      %t290 = arith.constant 6 : i32 loc(#loc615)
      %t291 = arith.index_cast %t290 : i32 to index
      %t292 = memref.load %t11[%t291] : memref<8xi32> loc(#loc616)
      %t293 = arith.constant 7 : i32 loc(#loc617)
      %t294 = arith.index_cast %t293 : i32 to index
      %t295 = memref.load %t11[%t294] : memref<8xi32> loc(#loc618)
      %t296 = arith.addi %t292, %t295 : i32 loc(#loc616)
      %t297 = arith.constant 3 : index
      memref.store %t296, %t10[%t297] : memref<8xi32>
      %t298 = arith.constant 6 : i32 loc(#loc619)
      %t299 = arith.index_cast %t298 : i32 to index
      %t300 = memref.load %t11[%t299] : memref<8xi32> loc(#loc620)
      %t301 = arith.constant 7 : i32 loc(#loc621)
      %t302 = arith.index_cast %t301 : i32 to index
      %t303 = memref.load %t11[%t302] : memref<8xi32> loc(#loc622)
      %t304 = arith.subi %t300, %t303 : i32 loc(#loc620)
      %t305 = arith.constant 4 : index
      memref.store %t304, %t10[%t305] : memref<8xi32>
      %t306 = arith.constant 2 : i32 loc(#loc623)
      %t307 = arith.index_cast %t306 : i32 to index
      %t308 = memref.load %t11[%t307] : memref<8xi32> loc(#loc624)
      %t309 = arith.constant 3 : i32 loc(#loc625)
      %t310 = arith.index_cast %t309 : i32 to index
      %t311 = memref.load %t11[%t310] : memref<8xi32> loc(#loc626)
      %t312 = arith.subi %t308, %t311 : i32 loc(#loc624)
      %t313 = arith.constant 5 : index
      memref.store %t312, %t10[%t313] : memref<8xi32>
      %t314 = arith.constant 4 : i32 loc(#loc627)
      %t315 = arith.index_cast %t314 : i32 to index
      %t316 = memref.load %t11[%t315] : memref<8xi32> loc(#loc628)
      %t317 = arith.constant 5 : i32 loc(#loc629)
      %t318 = arith.index_cast %t317 : i32 to index
      %t319 = memref.load %t11[%t318] : memref<8xi32> loc(#loc630)
      %t320 = arith.subi %t316, %t319 : i32 loc(#loc628)
      %t321 = arith.constant 6 : index
      memref.store %t320, %t10[%t321] : memref<8xi32>
      %t322 = arith.constant 0 : i32 loc(#loc631)
      %t323 = arith.index_cast %t322 : i32 to index
      %t324 = memref.load %t11[%t323] : memref<8xi32> loc(#loc632)
      %t325 = arith.constant 1 : i32 loc(#loc633)
      %t326 = arith.index_cast %t325 : i32 to index
      %t327 = memref.load %t11[%t326] : memref<8xi32> loc(#loc634)
      %t328 = arith.subi %t324, %t327 : i32 loc(#loc632)
      %t329 = arith.constant 7 : index
      memref.store %t328, %t10[%t329] : memref<8xi32>
      %t330 = arith.constant 8 : i32 loc(#loc635)
      %t331 = arith.index_cast %t330 : i32 to index
      %t332 = arith.constant 0 : index
      %t333 = arith.constant 1 : index
      scf.for %t334 = %t332 to %t331 step %t333 {
        %t335 = memref.load %t10[%t334] : memref<8xi32>
        fifo.push(%OUT: !fifo.input_port<i32>, %t335: i32)
        scf.yield
      }
    } loc(#loc493)
  } loc(#loc636)
  cal.actor @jpeg_decoder_parallel_idct__Transpose__v__index_2(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i32>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc637)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "$untagged0" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc639)
      %t11 = arith.constant 7 : i32 loc(#loc640)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 0 : i32 loc(#loc641)
      %t17 = arith.constant 7 : i32 loc(#loc642)
      %t18 = arith.index_cast %t16 : i32 to index
      %t19 = arith.index_cast %t17 : i32 to index
      %t20 = arith.constant 1 : index
      %t21 = arith.addi %t19, %t20 : index
      %t22 = arith.constant 1 : index
      scf.for %t23 = %t12 to %t15 step %t22 {
        %t24 = arith.index_cast %t23 : index to i32
        scf.for %t25 = %t18 to %t21 step %t22 {
          %t26 = arith.index_cast %t25 : index to i32
          %t27 = arith.constant 8 : i32 loc(#loc643)
          %t29 = arith.extsi %t27 : i32 to i64
          %t30 = arith.extsi %t26 : i32 to i64
          %t28 = arith.muli %t29, %t30 : i64 loc(#loc643)
          %t31 = arith.extsi %t24 : i32 to i64
          %t32 = arith.addi %t28, %t31 : i64 loc(#loc643)
          %t33 = arith.index_cast %t32 : i64 to index
          %t34 = memref.load %t4[%t33] : memref<64xi32> loc(#loc644)
          fifo.push(%OUT: !fifo.input_port<i32>, %t34: i32)
          scf.yield
        }
        scf.yield
      }
    } loc(#loc638)
  } loc(#loc645)
  cal.actor @jpeg_decoder_parallel_idct__Rightshift__v__index_2(%index: i32)
    in_names ["IN"]
    out_names ["OUT"]
    ports_in(%IN: !fifo.output_port<i32>)
    ports_out(%OUT: !fifo.input_port<i8>)
  {
    %t0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    cal.set(%t0: !cal.state_ref<i32>, %index: i32)
    %t1 = cal.create_state_var<i64> : !cal.state_ref<i64>
    %t2 = arith.constant 0 : i32 loc(#loc646)
    %t3 = arith.extsi %t2 : i32 to i64
    cal.set(%t1: !cal.state_ref<i64>, %t3: i64)
    cal.action "shift" priority=0 {
      %t4 = memref.alloca() : memref<64xi32>
      %t5 = arith.constant 64 : index
      %t6 = arith.constant 0 : index
      %t7 = arith.constant 1 : index
      scf.for %t8 = %t6 to %t5 step %t7 {
        %t9 = fifo.pop(%IN: !fifo.output_port<i32> ) : i32
        memref.store %t9, %t4[%t8] : memref<64xi32>
        scf.yield
      }
      %t10 = arith.constant 0 : i32 loc(#loc648)
      %t11 = arith.constant 63 : i32 loc(#loc649)
      %t12 = arith.index_cast %t10 : i32 to index
      %t13 = arith.index_cast %t11 : i32 to index
      %t14 = arith.constant 1 : index
      %t15 = arith.addi %t13, %t14 : index
      %t16 = arith.constant 1 : index
      scf.for %t17 = %t12 to %t15 step %t16 {
        %t18 = arith.index_cast %t17 : index to i32
        %t19 = arith.index_cast %t18 : i32 to index
        %t20 = memref.load %t4[%t19] : memref<64xi32> loc(#loc650)
        %t21 = arith.constant 13 : i32 loc(#loc651)
        %t22 = arith.constant 0 : i32
        %t23 = arith.shrsi %t20, %t21 : i32 loc(#loc1)
        %t24 = arith.constant 128 : i32 loc(#loc652)
        %t25 = arith.addi %t23, %t24 : i32 loc(#loc653)
        %t26 = arith.constant 0 : i32 loc(#loc654)
        %t27 = arith.constant 255 : i32 loc(#loc655)
        %t28 = arith.constant 0 : i8
        %t29 = arith.cmpi sgt, %t25, %t27 : i32 loc(#loc656)
        %t32 = scf.if %t29 -> i32 {
          scf.yield %t27 : i32
        } else {
          %t30 = arith.cmpi slt, %t25, %t26 : i32 loc(#loc657)
          %t31 = scf.if %t30 -> i32 {
            scf.yield %t26 : i32
          } else {
            scf.yield %t25 : i32
          }
          scf.yield %t31 : i32
        }
        %t33 = arith.trunci %t32 : i32 to i8
        fifo.push(%OUT: !fifo.input_port<i8>, %t33: i8)
        scf.yield
      }
    } loc(#loc647)
  } loc(#loc658)
} loc(#loc659)
#loc0 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":3:42)
#loc1 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":3:41)
#loc2 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/Top_JPEG_Decoder_Parallel.cal":9:26)
#loc3 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":22:25)
#loc4 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":23:26)
#loc5 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":24:26)
#loc6 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":25:21)
#loc7 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":26:22)
#loc8 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/JpegDecoder.cal":27:22)
#loc9 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":172:18)
#loc10 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":173:26)
#loc11 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":175:5)
#loc12 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":177:26)
#loc13 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":177:31)
#loc14 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":178:30)
#loc15 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":178:22)
#loc16 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":179:26)
#loc17 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":179:20)
#loc18 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":187:26)
#loc19 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":187:16)
#loc20 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":187:36)
#loc21 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":190:24)
#loc22 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":195:5)
#loc23 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Display.cal":169:1)
#loc24 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":9:20)
#loc25 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":10:28)
#loc26 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":11:18)
#loc27 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":12:19)
#loc28 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":13:25)
#loc29 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":14:13)
#loc30 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":15:16)
#loc31 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":16:16)
#loc32 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":17:17)
#loc33 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":18:18)
#loc34 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":19:24)
#loc35 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":20:26)
#loc36 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":28:21)
#loc37 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":39:21)
#loc38 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":40:24)
#loc39 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":54:3)
#loc40 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":56:15)
#loc41 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":56:4)
#loc42 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":56:28)
#loc43 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":56:18)
#loc44 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":59:15)
#loc45 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":47:14)
#loc46 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":47:5)
#loc47 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":47:29)
#loc48 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":47:4)
#loc49 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":60:25)
#loc50 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":60:15)
#loc51 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":61:25)
#loc52 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":61:15)
#loc53 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":51:26)
#loc54 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":51:15)
#loc55 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":51:31)
#loc56 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":70:3)
#loc57 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":72:15)
#loc58 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":72:4)
#loc59 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":72:29)
#loc60 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":72:18)
#loc61 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":74:15)
#loc62 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":75:25)
#loc63 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":75:15)
#loc64 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":76:25)
#loc65 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":76:15)
#loc66 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":129:3)
#loc67 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":132:15)
#loc68 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":133:21)
#loc69 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":133:26)
#loc70 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":134:18)
#loc71 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":138:3)
#loc72 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":140:16)
#loc73 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":142:11)
#loc74 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:17)
#loc75 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:15)
#loc76 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:25)
#loc77 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:23)
#loc78 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:31)
#loc79 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:22)
#loc80 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:14)
#loc81 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":144:40)
#loc82 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":146:21)
#loc83 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":146:26)
#loc84 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":148:30)
#loc85 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":148:26)
#loc86 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":148:24)
#loc87 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":149:18)
#loc88 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":149:12)
#loc89 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":154:3)
#loc90 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":155:20)
#loc91 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":155:9)
#loc92 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":158:17)
#loc93 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":158:11)
#loc94 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":159:25)
#loc95 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":159:15)
#loc96 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":162:3)
#loc97 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":163:20)
#loc98 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":163:9)
#loc99 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":104:9)
#loc100 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":105:9)
#loc101 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":106:16)
#loc102 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":107:14)
#loc103 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":112:22)
#loc104 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":112:27)
#loc105 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":114:16)
#loc106 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":114:12)
#loc107 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":115:31)
#loc108 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":115:36)
#loc109 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":115:54)
#loc110 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":117:32)
#loc111 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":119:41)
#loc112 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":120:15)
#loc113 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":120:11)
#loc114 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":121:11)
#loc115 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":122:29)
#loc116 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":122:18)
#loc117 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":124:25)
#loc118 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":124:15)
#loc119 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":126:39)
#loc120 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":166:29)
#loc121 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":166:17)
#loc122 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":169:3)
#loc123 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":170:22)
#loc124 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":170:9)
#loc125 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":172:12)
#loc126 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":173:12)
#loc127 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":174:14)
#loc128 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":175:15)
#loc129 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":176:15)
#loc130 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":177:15)
#loc131 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":180:3)
#loc132 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":181:20)
#loc133 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":181:9)
#loc134 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":87:13)
#loc135 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":89:16)
#loc136 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":89:10)
#loc137 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":91:14)
#loc138 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":91:10)
#loc139 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":93:12)
#loc140 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":93:40)
#loc141 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":93:36)
#loc142 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":184:15)
#loc143 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":189:3)
#loc144 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":190:20)
#loc145 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":190:9)
#loc146 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":194:22)
#loc147 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":194:15)
#loc148 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":196:22)
#loc149 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":196:21)
#loc150 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":196:10)
#loc151 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":197:14)
#loc152 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":197:30)
#loc153 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":197:19)
#loc154 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":197:13)
#loc155 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":197:7)
#loc156 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":199:18)
#loc157 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":199:17)
#loc158 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":199:16)
#loc159 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":199:11)
#loc160 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":199:34)
#loc161 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":201:15)
#loc162 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":201:10)
#loc163 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":203:15)
#loc164 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":204:14)
#loc165 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":205:21)
#loc166 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":205:26)
#loc167 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":206:17)
#loc168 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":208:11)
#loc169 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":209:10)
#loc170 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":215:3)
#loc171 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":216:20)
#loc172 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":216:9)
#loc173 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":219:15)
#loc174 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":221:26)
#loc175 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":221:17)
#loc176 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":221:11)
#loc177 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":221:31)
#loc178 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":227:3)
#loc179 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":228:20)
#loc180 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":228:9)
#loc181 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":235:22)
#loc182 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":235:15)
#loc183 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":238:21)
#loc184 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":238:36)
#loc185 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":238:20)
#loc186 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":238:9)
#loc187 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":239:12)
#loc188 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":239:28)
#loc189 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":239:17)
#loc190 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":239:11)
#loc191 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":239:7)
#loc192 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":240:16)
#loc193 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":240:15)
#loc194 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":240:14)
#loc195 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":240:10)
#loc196 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":240:32)
#loc197 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":248:3)
#loc198 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:21)
#loc199 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:10)
#loc200 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:36)
#loc201 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:29)
#loc202 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:47)
#loc203 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":249:41)
#loc204 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":253:29)
#loc205 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":253:17)
#loc206 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":254:20)
#loc207 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":254:7)
#loc208 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":256:18)
#loc209 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":257:20)
#loc210 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":257:13)
#loc211 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":258:15)
#loc212 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":258:8)
#loc213 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":259:14)
#loc214 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":262:14)
#loc215 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":263:15)
#loc216 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":264:15)
#loc217 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":265:14)
#loc218 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":265:8)
#loc219 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":265:29)
#loc220 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":265:21)
#loc221 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":267:23)
#loc222 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":267:16)
#loc223 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":269:22)
#loc224 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":269:37)
#loc225 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":269:21)
#loc226 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":269:10)
#loc227 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":271:14)
#loc228 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":271:30)
#loc229 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":271:19)
#loc230 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":271:13)
#loc231 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":271:8)
#loc232 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":272:17)
#loc233 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":272:16)
#loc234 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":272:15)
#loc235 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":272:11)
#loc236 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":272:33)
#loc237 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":275:16)
#loc238 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":277:21)
#loc239 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":277:13)
#loc240 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":279:21)
#loc241 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":279:13)
#loc242 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":248:39)
#loc243 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":289:3)
#loc244 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":290:9)
#loc245 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":292:12)
#loc246 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":293:14)
#loc247 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":294:14)
#loc248 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":295:16)
#loc249 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":296:14)
#loc250 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":298:14)
#loc251 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":299:14)
#loc252 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":300:14)
#loc253 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":300:17)
#loc254 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":300:20)
#loc255 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/huffman/Huffman420.cal":3:2)
#loc256 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":6:29)
#loc257 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":7:29)
#loc258 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":10:3)
#loc259 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":13:21)
#loc260 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":13:13)
#loc261 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":11:49)
#loc262 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":17:3)
#loc263 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":22:20)
#loc264 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":22:12)
#loc265 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":18:53)
#loc266 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":33:3)
#loc267 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":36:21)
#loc268 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":36:13)
#loc269 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":34:53)
#loc270 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Splitter420.cal":4:2)
#loc271 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":6:29)
#loc272 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":7:32)
#loc273 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":8:14)
#loc274 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":11:3)
#loc275 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":18:21)
#loc276 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":18:13)
#loc277 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":12:49)
#loc278 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":29:3)
#loc279 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":30:53)
#loc280 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":46:3)
#loc281 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":47:53)
#loc282 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/Merger420.cal":4:2)
#loc283 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":10:18)
#loc284 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":10:17)
#loc285 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":11:15)
#loc286 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":12:29)
#loc287 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":50:2)
#loc288 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":52:13)
#loc289 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":53:15)
#loc290 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":53:14)
#loc291 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":54:12)
#loc292 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":55:17)
#loc293 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:9)
#loc294 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:7)
#loc295 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:14)
#loc296 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:25)
#loc297 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:23)
#loc298 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":56:30)
#loc299 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":62:2)
#loc300 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:19)
#loc301 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:17)
#loc302 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:27)
#loc303 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:25)
#loc304 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:33)
#loc305 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:24)
#loc306 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":65:38)
#loc307 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":66:22)
#loc308 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":66:20)
#loc309 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":67:22)
#loc310 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":67:13)
#loc311 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":70:2)
#loc312 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":71:20)
#loc313 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":71:8)
#loc314 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":73:24)
#loc315 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":73:14)
#loc316 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":74:22)
#loc317 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":74:13)
#loc318 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":77:2)
#loc319 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":78:19)
#loc320 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":78:8)
#loc321 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":80:15)
#loc322 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":80:14)
#loc323 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":83:2)
#loc324 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":84:23)
#loc325 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":84:9)
#loc326 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":84:46)
#loc327 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":84:32)
#loc328 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":89:2)
#loc329 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":90:22)
#loc330 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":90:8)
#loc331 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":95:2)
#loc332 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":96:22)
#loc333 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":96:8)
#loc334 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":99:13)
#loc335 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":102:2)
#loc336 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":103:20)
#loc337 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":103:8)
#loc338 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":105:24)
#loc339 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":105:14)
#loc340 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":108:2)
#loc341 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":109:22)
#loc342 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":109:8)
#loc343 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:17)
#loc344 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:15)
#loc345 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:21)
#loc346 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:28)
#loc347 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:26)
#loc348 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":115:8)
#loc349 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:17)
#loc350 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:15)
#loc351 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:21)
#loc352 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:28)
#loc353 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:26)
#loc354 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":116:8)
#loc355 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":108:47)
#loc356 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":108:42)
#loc357 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":108:55)
#loc358 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":108:50)
#loc359 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":119:2)
#loc360 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":120:22)
#loc361 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":120:8)
#loc362 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":125:2)
#loc363 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":126:20)
#loc364 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":126:8)
#loc365 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":128:24)
#loc366 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":128:14)
#loc367 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":129:22)
#loc368 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":129:13)
#loc369 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":132:2)
#loc370 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":133:22)
#loc371 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":133:8)
#loc372 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":138:2)
#loc373 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":139:14)
#loc374 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":139:8)
#loc375 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":141:22)
#loc376 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":141:13)
#loc377 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":142:18)
#loc378 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":142:11)
#loc379 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":145:2)
#loc380 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":146:13)
#loc381 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":146:8)
#loc382 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":148:22)
#loc383 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":148:13)
#loc384 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":153:2)
#loc385 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":154:13)
#loc386 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":154:8)
#loc387 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":156:18)
#loc388 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":156:11)
#loc389 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":157:22)
#loc390 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":157:13)
#loc391 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":153:37)
#loc392 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":160:2)
#loc393 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":161:13)
#loc394 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":161:8)
#loc395 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":164:22)
#loc396 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":164:13)
#loc397 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":167:2)
#loc398 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":167:29)
#loc399 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":167:32)
#loc400 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/ParseJPEG.cal":5:2)
#loc401 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":7:3)
#loc402 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":8:14)
#loc403 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":8:9)
#loc404 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":11:3)
#loc405 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":12:14)
#loc406 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":12:9)
#loc407 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":15:3)
#loc408 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":15:65)
#loc409 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":18:3)
#loc410 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":18:70)
#loc411 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":18:93)
#loc412 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/parser/SplitQT.cal":3:2)
#loc413 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":108:18)
#loc414 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":109:25)
#loc415 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":135:5)
#loc416 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":136:18)
#loc417 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":136:11)
#loc418 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":140:26)
#loc419 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":140:29)
#loc420 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":141:27)
#loc421 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":142:28)
#loc422 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":142:21)
#loc423 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":135:37)
#loc424 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":153:5)
#loc425 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":154:19)
#loc426 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":154:11)
#loc427 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":154:32)
#loc428 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":154:25)
#loc429 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":158:26)
#loc430 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":158:29)
#loc431 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":159:27)
#loc432 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":160:28)
#loc433 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":160:21)
#loc434 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":153:37)
#loc435 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":171:5)
#loc436 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":173:16)
#loc437 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":173:9)
#loc438 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":174:9)
#loc439 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":176:38)
#loc440 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":176:24)
#loc441 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":178:28)
#loc442 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":178:12)
#loc443 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":178:35)
#loc444 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":182:12)
#loc445 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":183:21)
#loc446 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/io/Source.cal":107:1)
#loc447 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":23:3)
#loc448 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":25:19)
#loc449 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":26:15)
#loc450 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":30:3)
#loc451 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":32:34)
#loc452 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":32:39)
#loc453 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":32:14)
#loc454 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":35:3)
#loc455 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":39:46)
#loc456 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":39:51)
#loc457 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":39:15)
#loc458 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":39:22)
#loc459 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":40:25)
#loc460 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":40:15)
#loc461 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":35:88)
#loc462 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":35:93)
#loc463 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":35:62)
#loc464 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":35:55)
#loc465 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":43:3)
#loc466 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":45:4)
#loc467 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/dequant/Dequant.cal":3:2)
#loc468 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":7:11)
#loc469 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":9:11)
#loc470 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":11:11)
#loc471 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":13:11)
#loc472 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":15:11)
#loc473 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":17:11)
#loc474 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":19:11)
#loc475 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":21:11)
#loc476 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":23:11)
#loc477 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":25:11)
#loc478 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":32:26)
#loc479 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":34:3)
#loc480 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":38:49)
#loc481 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":38:54)
#loc482 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":38:11)
#loc483 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":38:18)
#loc484 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":39:6)
#loc485 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":39:14)
#loc486 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":39:12)
#loc487 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":39:19)
#loc488 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":41:21)
#loc489 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":41:13)
#loc490 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":34:56)
#loc491 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scale.cal":3:2)
#loc492 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":44:25)
#loc493 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":46:3)
#loc494 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":52:17)
#loc495 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":52:10)
#loc496 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":52:29)
#loc497 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":52:22)
#loc498 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":53:17)
#loc499 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":53:10)
#loc500 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":53:29)
#loc501 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":53:22)
#loc502 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":54:11)
#loc503 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":54:29)
#loc504 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":54:22)
#loc505 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":54:17)
#loc506 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":55:11)
#loc507 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":55:29)
#loc508 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":55:22)
#loc509 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":55:17)
#loc510 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":56:11)
#loc511 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":56:29)
#loc512 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":56:22)
#loc513 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":56:17)
#loc514 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":57:11)
#loc515 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":57:29)
#loc516 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":57:22)
#loc517 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":57:17)
#loc518 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":58:29)
#loc519 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":58:22)
#loc520 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":9:26)
#loc521 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":9:41)
#loc522 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":9:16)
#loc523 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":10:4)
#loc524 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":59:29)
#loc525 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":59:22)
#loc526 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":15:26)
#loc527 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":15:41)
#loc528 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":15:16)
#loc529 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":16:34)
#loc530 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":16:16)
#loc531 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":17:26)
#loc532 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":17:4)
#loc533 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":60:29)
#loc534 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":60:22)
#loc535 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":61:29)
#loc536 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":61:22)
#loc537 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":62:11)
#loc538 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":62:17)
#loc539 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":63:11)
#loc540 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":63:17)
#loc541 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":64:29)
#loc542 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":64:22)
#loc543 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":22:26)
#loc544 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":22:16)
#loc545 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":23:18)
#loc546 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":23:4)
#loc547 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":65:29)
#loc548 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":65:22)
#loc549 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":27:14)
#loc550 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":66:29)
#loc551 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":66:22)
#loc552 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":67:29)
#loc553 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":67:22)
#loc554 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":68:11)
#loc555 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":68:17)
#loc556 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":69:11)
#loc557 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":69:17)
#loc558 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":70:29)
#loc559 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":70:22)
#loc560 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":32:30)
#loc561 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":32:16)
#loc562 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":33:30)
#loc563 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":34:22)
#loc564 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":34:4)
#loc565 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":71:29)
#loc566 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":71:22)
#loc567 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":39:30)
#loc568 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":39:16)
#loc569 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":40:30)
#loc570 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":41:4)
#loc571 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":72:29)
#loc572 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":72:22)
#loc573 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":73:29)
#loc574 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":73:22)
#loc575 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":74:11)
#loc576 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":74:17)
#loc577 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":75:11)
#loc578 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":75:17)
#loc579 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":76:17)
#loc580 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":76:10)
#loc581 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":76:29)
#loc582 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":76:22)
#loc583 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":77:17)
#loc584 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":77:10)
#loc585 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":77:29)
#loc586 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":77:22)
#loc587 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":78:11)
#loc588 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":78:29)
#loc589 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":78:22)
#loc590 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":78:17)
#loc591 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":79:11)
#loc592 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":79:29)
#loc593 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":79:22)
#loc594 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":79:17)
#loc595 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":80:11)
#loc596 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":80:29)
#loc597 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":80:22)
#loc598 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":80:17)
#loc599 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":81:11)
#loc600 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":81:29)
#loc601 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":81:22)
#loc602 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":81:17)
#loc603 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:18)
#loc604 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:11)
#loc605 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:30)
#loc606 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:23)
#loc607 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:41)
#loc608 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:34)
#loc609 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:53)
#loc610 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:46)
#loc611 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:64)
#loc612 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:57)
#loc613 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:76)
#loc614 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:69)
#loc615 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:87)
#loc616 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:80)
#loc617 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:99)
#loc618 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:92)
#loc619 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:110)
#loc620 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:103)
#loc621 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:122)
#loc622 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:115)
#loc623 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:133)
#loc624 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":82:126)
#loc625 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:13)
#loc626 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:6)
#loc627 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:24)
#loc628 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:17)
#loc629 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:36)
#loc630 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:29)
#loc631 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:47)
#loc632 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:40)
#loc633 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:59)
#loc634 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":83:52)
#loc635 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":46:49)
#loc636 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Scaled_1d_idct.cal":3:2)
#loc637 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":7:29)
#loc638 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:3)
#loc639 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:69)
#loc640 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:74)
#loc641 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:90)
#loc642 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:95)
#loc643 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:43)
#loc644 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":9:41)
#loc645 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Transpose.cal":3:2)
#loc646 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":9:29)
#loc647 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:3)
#loc648 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:104)
#loc649 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:109)
#loc650 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:65)
#loc651 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:71)
#loc652 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:77)
#loc653 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:58)
#loc654 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:82)
#loc655 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":26:85)
#loc656 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":15:7)
#loc657 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":18:8)
#loc658 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/decoder/parallel/idct/Rightshift.cal":5:2)
#loc659 = loc("/mnt/kingston/gareth/software-repos/languim-cal/examples/jpeg/Top_JPEG_Decoder_Parallel.cal":1:1)