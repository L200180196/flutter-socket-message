const express = require('express');

const app = express()
const PORT = process.env.PORT || 2000
const server = app.listen(PORT, () => {
    console.log("Server Started on", PORT)
})

const io = require('socket.io')(server)
const connectUser = new Set()
io.on('connection',(socket) => {
    const dateTime = new Date().toLocaleTimeString();
    console.log("Connected Successfully", socket.id)
    console.log(dateTime)
    connectUser.add(socket.id)
    io.emit('connected-user', connectUser.size)
    socket.on('disconnect', () => {
        console.log("Disconnected", socket.id)
        connectUser.delete(socket.id)
        io.emit('connected-user', connectUser.size)
    })

    socket.on('message', (data) => {
        console.log(data)
        socket.broadcast.emit('message-receive', data)
    })
})
