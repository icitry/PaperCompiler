from typing import Optional

import cv2
import numpy as np
from PIL import Image
from fastapi import FastAPI, Response, status, UploadFile, Form, File

from defs import Constants
from imggen import HandwritingConverter
from ocr import OCRController
from service import FirebaseService, CodeCompilationService

app = FastAPI()

ocr_controller = OCRController()
handwriting_converter = HandwritingConverter()

firebase_service = FirebaseService()
code_compilation_service = CodeCompilationService()


@app.post("/register")
def register_user(handwriting_image: UploadFile, response: Response):
    handwriting_image = Image.open(handwriting_image.file)
    handwriting_image = np.array(handwriting_image)

    handwriting_dict = ocr_controller.parse_user_handwriting_dict(image=handwriting_image)
    user_uuid = firebase_service.register_user(handwriting_dict)
    if user_uuid is None:
        response.status_code = status.HTTP_401_UNAUTHORIZED
        return {"error": "Could not register user."}

    return {"data": {"id": user_uuid}}


@app.post("/compile")
def compile_code(response: Response,
                 user_id: str = Form(...),
                 language_id: str = Form(...),
                 code_image: UploadFile = File(...),
                 code_input_image: Optional[UploadFile] = File(None),
                 ):
    code_img = Image.open(code_image.file)
    code_img = np.array(code_img)

    if code_input_image:
        code_input_img = Image.open(code_input_image.file)
        code_input_img = np.array(code_input_img)
    else:
        code_input_img = None

    code, code_input = ocr_controller.parse_code_input_text(code_img=code_img,
                                                            code_input_img=code_input_img)
    stdout = code_compilation_service.compile_code(code, code_input, language_id)

    if stdout is None:
        response.status_code = status.HTTP_400_BAD_REQUEST
        return {"error": "Could not compile code."}

    user_handwriting_dict = firebase_service.get_user_handwriting_dict(user_id=user_id)
    stdout_img = handwriting_converter.convert_text_to_user_handwriting(text=stdout,
                                                                        handwriting_dict=user_handwriting_dict)

    res, stdout_img = cv2.imencode('.png', stdout_img)

    if not res:
        response.status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
        return {"error": "Could not generate output image."}

    return Response(content=stdout_img.tobytes(), media_type="image/png")


@app.get("/languages")
def get_available_languages():
    return {'data': Constants.AVAILABLE_LANGUAGES}
