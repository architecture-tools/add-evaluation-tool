# Как просмотреть API документацию

## После публикации на GitHub Pages

1. Дождитесь завершения workflow "Deploy GitHub Pages" (запускается автоматически при push в main)
2. Откройте в браузере:
   ```
   https://architecture-tools.github.io/add-evaluation-tool/api/
   ```

## Локальный просмотр (до публикации)

### Вариант 1: Через локальный сервер

```bash
# В корне проекта
cd docs/api
python3 -m http.server 8001
# Откройте http://localhost:8001/index.html
```

### Вариант 2: Через Redoc CLI

```bash
npx @redocly/cli preview-docs backend/openapi/openapi.json
```

### Вариант 3: Через Swagger UI (Docker)

```bash
docker run -p 8080:8080 \
  -e SWAGGER_JSON=/openapi.json \
  -v $(pwd)/backend/openapi:/openapi \
  swaggerapi/swagger-ui
# Откройте http://localhost:8080
```

## Обновление документации

OpenAPI спецификация автоматически обновляется при изменении API. Для ручного обновления:

```bash
# Запустите backend
cd backend && poetry run uvicorn main:app --reload

# В другом терминале экспортируйте спецификацию
curl http://localhost:8000/openapi.json > backend/openapi/openapi.json

# Закоммитьте изменения
git add backend/openapi/openapi.json docs/api/openapi.json
git commit -m "Update OpenAPI specification"
git push
```

GitHub Pages автоматически пересоберется и опубликует обновленную документацию.

