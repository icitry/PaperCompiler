from numpy import asarray
from ocr.CharactersParser import CharactersParser
from paddleocr import PaddleOCR


class OCRController:
    def __init__(self):
        self._ocr = PaddleOCR(use_angle_cls=True, lang='en')
        self._chars_parser = CharactersParser()

    def _parse_line_tabs(self, line):
        index_of_non_underscore = next((i for i, char in enumerate(line) if char != '-'), len(line))

        modified_str = line[:index_of_non_underscore].replace('-', '\t') + line[index_of_non_underscore:]

        return modified_str

    def _parse_text_content(self, img, is_code):
        result = self._ocr.ocr(img, cls=True)

        text = ''

        for idx in range(len(result)):
            res = result[idx]
            if res is None:
                continue

            for line in res:
                line_text = str(line[1][0])
                if is_code:
                    line_text = self._parse_line_tabs(line_text)
                text += f'{line_text}\n'

        if len(text) >= 1 and text[-1] == '\n':
            text = text[:-1]

        return text

    def parse_code_input_text(self, code_img, code_input_img=None):
        code = self._parse_text_content(code_img, is_code=True)

        if code_input_img is not None:
            code_input = self._parse_text_content(code_input_img, is_code=False)
        else:
            code_input = None

        return code, code_input

    def parse_user_handwriting_dict(self, image):
        chars = self._chars_parser.get_chars_from_image(image)

        handwriting_dict = dict()

        for char in chars:
            result = self._ocr.ocr(asarray(char), cls=True)
            if result[0] is None:
                continue
            line = result[0][0]
            char_text = str(line[1][0])
            handwriting_dict[char_text] = char

        return handwriting_dict
