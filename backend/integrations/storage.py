import os
import uuid
import logging
from django.core.files.base import ContentFile
from PIL import Image
from io import BytesIO

logger = logging.getLogger(__name__)

class StorageService:
    @staticmethod
    def process_and_upload_image(file, max_width=1200, quality=85):
        try:
            img = Image.open(file)
            
            # Convert RGBA to RGB if necessary for JPEG
            if img.mode in ("RGBA", "P"):
                img = img.convert("RGB")
            
            # Resize
            if img.width > max_width:
                output_size = (max_width, int(img.height * (max_width / img.width)))
                img = img.resize(output_size, Image.LANCZOS)
            
            # Save to buffer
            buffer = BytesIO()
            img.save(buffer, format="JPEG", quality=quality)
            buffer.seek(0)
            
            filename = f"{uuid.uuid4()}.jpg"
            return ContentFile(buffer.read(), name=filename)
        except Exception as e:
            logger.error(f"Image processing error: {e}")
            return file

    @staticmethod
    def validate_audio(file):
        # Basic extension check, could use magic numbers for better validation
        ext = os.path.splitext(file.name)[1].lower()
        allowed_exts = ['.m4a', '.mp3', '.wav', '.aac', '.ogg']
        return ext in allowed_exts
