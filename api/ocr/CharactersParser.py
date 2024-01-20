import os.path

import cv2
import numpy as np
from imutils import contours as cnts


class CharactersParser:
    _CHAR_IMG_HEIGHT = 110
    _CHAR_IMG_WIDTH = 80

    def get_chars_from_image(self, image):
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_OTSU + cv2.THRESH_BINARY_INV)[1]

        contours = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        contours = contours[0] if len(contours) == 2 else contours[1]
        contours, _ = cnts.sort_contours(contours, method="left-to-right")

        chars = list()
        for c in contours:
            area = cv2.contourArea(c)
            if area > 10:
                x, y, w, h = cv2.boundingRect(c)
                roi = image[y:y + h, x:x + w]

                roi_height, roi_width, roi_channels = roi.shape
                color = (255, 255, 255)
                result = np.full((self._CHAR_IMG_HEIGHT, self._CHAR_IMG_WIDTH, roi_channels), color, dtype=np.uint8)

                start_row = max(0, int((result.shape[0] - roi_height) / 2))
                start_col = max(0, int((result.shape[1] - roi_width) / 2))

                # Calculate the end coordinates
                end_row = min(start_row + roi_height, result.shape[0])
                end_col = min(start_col + roi_width, result.shape[1])

                # Calculate the region where the smaller image will be placed
                region = result[start_row:end_row, start_col:end_col]

                # Place the smaller image in the center of the larger image
                region[:roi_height, :roi_width] = roi

                chars.append(result)

        return chars
