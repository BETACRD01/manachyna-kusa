import logging
from rest_framework.response import Response

logger = logging.getLogger(__name__)

class StandardResponseMixin:
    def finalize_response(self, request, response, *args, **kwargs):
        if response.status_code >= 200 and response.status_code < 400:
            if not isinstance(response.data, dict) or 'success' not in response.data:
                response.data = {
                    'success': True,
                    'message': 'Success',
                    'data': response.data,
                    'errors': None
                }
        return super().finalize_response(request, response, *args, **kwargs)
