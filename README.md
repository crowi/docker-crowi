# docker-crowi
Crowi wiki on Docker

## Example docker-compose.yml

```yaml
crowi:
    image: bakudankun/crowi
    links:
        - db
        - redis
    ports:
        - 8080:3000

db:
    image: mongo

redis:
    image: redis:alpine
```
