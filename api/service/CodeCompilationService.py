import base64

import requests
from defs import Constants


class CodeCompilationService:
    def compile_code(self, code, code_input, language_id):
        if code_input is None:
            code_input = ''

        data = {
            'source_code': base64.b64encode(code.encode('utf-8')),
            'language_id': language_id,
            'stdin': base64.b64encode(code_input.encode('utf-8')),
            'compiler_options': '',
            'command_line_arguments': '',
            'redirect_stderr_to_stdout': True,
        }

        response = requests.post(
            url=f'{Constants.JUDGE0_URL}/submissions?base64_encoded=true&wait=true',
            data=data,
            timeout=Constants.REQUEST_IPV4_TIMEOUT_SECONDS)

        if not response.ok:
            return None

        response = response.json()

        stdout = response.get('stdout')
        if stdout is not None:
            return base64.b64decode(stdout)
        else:
            return None
