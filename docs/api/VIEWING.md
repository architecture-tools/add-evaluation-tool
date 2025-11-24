# Как просмотреть API документацию

## После публикации на GitHub Pages

1. Дождитесь завершения workflow "Deploy GitHub Pages" (запускается автоматически при push в main)
2. Откройте в браузере:

   ```text
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

OpenAPI спецификация **автоматически обновляется** при каждом push в `main`:

1. CI/CD workflow запускает backend сервер
2. Экспортирует актуальную OpenAPI спецификацию из `/openapi.json`
3. Автоматически коммитит обновленный `openapi.json` обратно в репозиторий
4. GitHub Pages автоматически пересобирается и публикует обновленную документацию

**Вам не нужно обновлять openapi.json вручную!** Просто измените API код,
закоммитьте и запушьте - всё остальное произойдет автоматически.

### Ручное обновление (для локальной разработки)

Если нужно обновить спецификацию локально:

```bash
# Запустите backend
cd backend && poetry run uvicorn main:app --reload

# В другом терминале экспортируйте спецификацию
curl http://localhost:8000/openapi.json > backend/openapi/openapi.json
cp backend/openapi/openapi.json docs/api/openapi.json
```
