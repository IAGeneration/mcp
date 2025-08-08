import { Elysia } from 'elysia'

const app =new Elysia()
    .get('/hello', () => 'Hello from MCP pod!')
    .get('/', () => 'Hello root!')
    .listen(3000)

console.log(' Bun/Elysia hello running on 3000 port')