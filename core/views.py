from django.http import HttpResponse, JsonResponse
def index(request):
    return HttpResponse("Hello from Django in Docker with PostgreSQL and Nginx!")
def health(request):
    return JsonResponse({"status": "ok"})
