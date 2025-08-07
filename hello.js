import { Elysia } from 'elysia'

const app =new Elysia()
    .get('/hello', () => 'Hello from MCP pod!')
    .listen(3000)

console.log(' Bun/Elysia hello running on 3000 port')