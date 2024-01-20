import base64

import numpy as np
from defs import Constants
from firebase_admin import credentials, firestore, initialize_app


class FirebaseService:
    def __init__(self, name='default', collection_name='users'):
        if Constants.FIREBASE_SERVICE_ACCOUNT_CREDENTIALS_PATH is None:
            raise Exception('No path to Firebase credentials provided in config.')

        self._cred = credentials.Certificate(Constants.FIREBASE_SERVICE_ACCOUNT_CREDENTIALS_PATH)
        self._app = initialize_app(self._cred, name=name)
        self._db = firestore.client(self._app)
        self._collection_name = collection_name

    def _encode_image_for_storage(self, img_data):
        shape_str = ','.join(map(str, img_data.shape))
        return shape_str.encode('utf-8') + b'\x00' + img_data.tobytes()

    def _decode_image_data(self, data_str):
        shape_end = data_str.index(b'\x00')
        shape_str = data_str[:shape_end].decode('utf-8')
        data = data_str[shape_end + 1:]
        shape = tuple(map(int, shape_str.split(',')))
        return np.frombuffer(data, dtype=np.uint8).reshape(shape)

    def register_user(self, handwriting_dict):
        handwriting_dict = {k: self._encode_image_for_storage(v) for k, v in handwriting_dict.items()}

        update_time, doc_ref = self._db.collection(self._collection_name).add({
            'handwriting_dict_entries': len(handwriting_dict.keys())
        })

        if doc_ref is None:
            return None

        for k, v in handwriting_dict.items():
            doc_ref.collection('entries').add({
                'key': k,
                'value': v
            })

        return str(doc_ref.id)

    def get_user_handwriting_dict(self, user_id):
        user_handwriting_dict = dict()

        user_handwriting_entries = \
            self._db.collection(self._collection_name).document(user_id).collection('entries').stream()

        for entry in user_handwriting_entries:
            entry_dict = entry.to_dict()

            key = entry_dict.get('key')
            value = entry_dict.get('value')
            if key is None or value is None:
                continue

            user_handwriting_dict[key] = self._decode_image_data(value)

        return user_handwriting_dict
