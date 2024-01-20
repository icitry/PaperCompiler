import numpy as np


class HandwritingConverter:
    def convert_text_to_user_handwriting(self, text, handwriting_dict: dict):
        if len(handwriting_dict.keys()) < 1:
            return None

        char_height, char_width, _ = handwriting_dict[list(handwriting_dict.keys())[0]].shape
        canvas_width = char_width * max(len(line) for line in text.split('\n'))
        canvas_height = char_height * len(text.split('\n'))
        canvas = np.ones((canvas_height, canvas_width, 3), dtype=np.uint8)

        current_y = 0
        for line in text.split('\n'):
            current_x = 0
            for char in line:
                if char == ' ':
                    current_x += char_width
                    continue

                char_image = handwriting_dict.get(char)

                if char_image is None:
                    continue

                canvas[current_y:current_y + char_height, current_x:current_x + char_width, :] = char_image
                current_x += char_width

            current_y += char_height

        return canvas
