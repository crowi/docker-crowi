# docker-crowi

[![Join the chat at https://gitter.im/Bakudankun/docker-crowi](https://badges.gitter.im/Bakudankun/docker-crowi.svg)](https://gitter.im/Bakudankun/docker-crowi?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
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
