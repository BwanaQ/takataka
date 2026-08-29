from django.http import JsonResponse
from django.utils import timezone

def health(request):
    return JsonResponse({
        "status": "ok",
        "service": "taka-taka-api",
        "timestamp": timezone.now().isoformat(),
    })
