from rest_framework.views import exception_handler
from rest_framework.response import Response
from rest_framework import status
import logging

logger = logging.getLogger(__name__)

def custom_exception_handler(exc, context):
    # Call DRF's default exception handler first to get the standard error response.
    response = exception_handler(exc, context)

    if response is not None:
        custom_data = {
            'success': False,
            'message': 'Error en la solicitud',
            'data': None,
            'errors': response.data
        }
        response.data = custom_data
    else:
        # Handle non-DRF exceptions (500 errors)
        logger.error(f"Unhandled Exception: {exc}", exc_info=True)
        return Response({
            'success': False,
            'message': 'Error interno del servidor',
            'data': None,
            'errors': {'detail': 'No se pudo procesar la solicitud'}
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    return response
