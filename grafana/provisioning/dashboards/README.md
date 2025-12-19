# Provisioned Dashboards

Все дашборды автоматически создаются при запуске Grafana.

## Список дашбордов:

1. **API Availability SLO** - Мониторинг доступности API и времени отклика
2. **PlantUML Parsing Performance** - Производительность парсинга диаграмм
3. **Analytics - North Star Metric** - Бизнес-метрики и аналитика
4. **System Health** - Общее здоровье системы
5. **Diagram Operations Deep Dive** - Детальная аналитика операций с диаграммами
6. **Request Size & Throughput** - Размер запросов и пропускная способность
7. **Database Performance** - Производительность базы данных

## Как это работает:

- Дашборды автоматически создаются при запуске Grafana
- Обновляются каждые 10 секунд (если изменены JSON файлы)
- Можно редактировать в UI (изменения сохраняются в volume)
- Для версионирования: экспортируйте изменения обратно в JSON

## После перезапуска Grafana:

```bash
docker-compose restart grafana
```

Дашборды автоматически появятся в Grafana UI.

## Если дашборды не появились:

1. Проверьте логи Grafana:
   ```bash
   docker-compose logs grafana | grep -i dashboard
   ```

2. Проверьте, что datasource "Prometheus" создан:
   - Откройте Grafana → Configuration → Data Sources
   - Должен быть datasource "Prometheus"

3. Проверьте формат JSON файлов:
   ```bash
   python3 -m json.tool grafana/provisioning/dashboards/api-availability-slo.json
   ```

## Экспорт изменений из UI:

Если вы изменили дашборд в UI и хотите сохранить изменения в Git:

1. Откройте дашборд в Grafana
2. Settings (шестеренка) → JSON Model
3. Скопируйте JSON
4. Сохраните в соответствующий файл в этой папке
5. Коммитьте изменения в Git


