(async () => {
    const qrcode = (await import('qrcode-terminal')).default;
    const pino = (await import('pino')).default;
    const { default: makeWASocket, Browsers, useMultiFileAuthState, fetchLatestBaileysVersion } = (await import('@whiskeysockets/baileys')).default;
    const fs = (await import('fs')).default;
    const schedule = (await import('node-schedule')).default;
    const moment = (await import('moment-timezone')).default;

    async function startBot() {
        let { version } = await fetchLatestBaileysVersion();
        const { state, saveCreds } = await useMultiFileAuthState('./sessions');

        const bot = makeWASocket({
            logger: pino({ level: 'silent' }),
            printQRInTerminal: false,
            browser: Browsers.windows('Chrome'),
            version,
            auth: state,
        });

        let qrShown = false;
        const startTime = moment(); // Armazena o tempo de início
        const scheduledJobs = {}; // Armazena os trabalhos agendados

        async function reScheduleMessages() {
            const scheduledMessages = await loadScheduledMessages();
            const now = moment().tz('America/Sao_Paulo');

            for (const [messageId, { groupId, messageText, scheduleDate }] of Object.entries(scheduledMessages)) {
                const scheduleMoment = moment(scheduleDate).tz('America/Sao_Paulo');

                if (scheduleMoment.isAfter(now)) {
                    const job = schedule.scheduleJob(scheduleMoment.toDate(), async () => {
                        await bot.sendMessage(groupId, { text: messageText });
                        console.log(`Mensagem programada enviada no grupo ${groupId}`);

                        delete scheduledMessages[messageId];
                        await saveScheduledMessages(scheduledMessages);
                        delete scheduledJobs[messageId]; // Remover o trabalho agendado
                    });

                    scheduledJobs[messageId] = job; // Salvar o trabalho agendado
                    console.log(`Reagendada mensagem ${messageId} para ${scheduleMoment.format('DD/MM/YYYY HH:mm:ss')}`);
                }
            }
        }

        async function handleGroupCommand(messageText) {
            try {
                const groups = await bot.groupFetchAllParticipating();
                let groupList = '';
                let count = 1;
                const groupIds = {};

                for (const groupId in groups) {
                    groupList += `${count} - ${groups[groupId].subject}\n`;
                    groupIds[count] = groupId;
                    count++;
                }

                if (!messageText) {
                    await bot.sendMessage(bot.user.id, { text: `Grupos Participantes:\n\n${groupList}` });
                    return;
                }

                const selectedNumber = parseInt(messageText.trim());
                if (!isNaN(selectedNumber) && selectedNumber in groupIds) {
                    const selectedGroupId = groupIds[selectedNumber];
                    fs.writeFileSync('group.txt', selectedGroupId, 'utf-8');
                    await bot.sendMessage(selectedGroupId, { text: 'O bot está operando aqui!' });
                } else {
                    console.log('Número de grupo inválido.');
                    await bot.sendMessage(bot.user.id, { text: 'Número de grupo inválido.' });
                }
            } catch (err) {
                console.log('Erro ao listar os grupos: ', err);
            }
        }

        async function sendMenu() {
            const menuContent = `
┏ 📋 *Menu de Comandos*
┃ 
┃ 1. **Definir Grupo** /group [número do grupo]
┃    - Define um grupo para o bot.
┃ 
┃ 2. **Programar Mensagem** /prog
┃    - Programar mensagem.
┃ 
┃ 3. **Excluir Mensagens** /delete
┃    - Exclui mensagens específicas.
┃ 
┃ 4. **Ver Mensagens** /view
┃    - Mostra mensagens recentes.
┃ 
┃ 5. **Info** /info
┃    - Informações sobre o bot.
┃ 
┃   Digite o comando desejado.
┃ 
┃ _Criado por: Andre_
┗━━━━━━━━━━
            `;
            await bot.sendMessage(bot.user.id, { text: menuContent });
            console.log('Menu enviado para o próprio número!');
        }

        async function handleProgCommand(userId, messageText) {
            const parts = messageText.split('|').map(part => part.trim());

            if (parts.length !== 2) {
                await bot.sendMessage(userId, { text: 'Formato inválido. Use o formato "/prog Mensagem | dd/MM HH:mm:ss".' });
                return;
            }

            const messageContent = parts[0];
            const dateStr = parts[1];

            await scheduleMessage(userId, messageContent, dateStr);
        }

        async function scheduleMessage(userId, messageContent, dateStr) {
            try {
                const [dayMonth, time] = dateStr.split(' ');
                const [day, month, year] = dayMonth.split('/');
                const [hour, minute, second] = time.split(':');

                if (!day || !month || !year || !hour || !minute || !second) {
                    await bot.sendMessage(userId, { text: 'Formato de data ou hora inválido. Use o formato "dd/MM/yyyy HH:mm:ss".' });
                    return;
                }

                const scheduleDate = moment.tz(`${year}-${month}-${day} ${hour}:${minute}:${second}`, 'YYYY-MM-DD HH:mm:ss', 'America/Sao_Paulo');

                if (!scheduleDate.isValid()) {
                    await bot.sendMessage(userId, { text: 'Data e hora inválidas.' });
                    return;
                }

                const now = moment().tz('America/Sao_Paulo');
                if (scheduleDate.isBefore(now)) {
                    await bot.sendMessage(userId, { text: 'Não é possível agendar uma mensagem no passado.' });
                    return;
                }

                const groupId = fs.readFileSync('group.txt', 'utf-8');
                if (!groupId) {
                    await bot.sendMessage(userId, { text: 'Nenhum grupo definido. Use o comando /group primeiro.' });
                    return;
                }

                const scheduledMessages = await loadScheduledMessages();
                const messageId = Date.now().toString();
                scheduledMessages[messageId] = { groupId, messageText: messageContent, scheduleDate: scheduleDate.format() };

                await saveScheduledMessages(scheduledMessages);

                // Agendar a mensagem e armazenar a referência no objeto scheduledJobs
                const job = schedule.scheduleJob(scheduleDate.toDate(), async () => {
                    await bot.sendMessage(groupId, { text: messageContent });
                    console.log(`Mensagem programada enviada no grupo ${groupId}`);

                    delete scheduledMessages[messageId];
                    await saveScheduledMessages(scheduledMessages);
                    delete scheduledJobs[messageId]; // Remover o trabalho agendado
                });

                scheduledJobs[messageId] = job; // Salvar o trabalho agendado

                await bot.sendMessage(userId, { text: `Mensagem programada para ${scheduleDate.format('DD/MM/YYYY HH:mm:ss')}` });
                console.log(`Mensagem programada para ${scheduleDate.format('DD/MM/YYYY HH:mm:ss')}`);
            } catch (err) {
                console.log('Erro ao programar a mensagem: ', err);
                await bot.sendMessage(userId, { text: 'Erro ao programar a mensagem. Verifique o formato e tente novamente.' });
            }
        }

        async function loadScheduledMessages() {
            try {
                const data = fs.readFileSync('scheduledMessages.json', 'utf-8');
                return JSON.parse(data);
            } catch (err) {
                return {};
            }
        }

        async function saveScheduledMessages(messages) {
            try {
                fs.writeFileSync('scheduledMessages.json', JSON.stringify(messages, null, 2), 'utf-8');
            } catch (err) {
                console.log('Erro ao salvar mensagens programadas: ', err);
            }
        }

        async function handleViewCommand(userId) {
            try {
                const scheduledMessages = await loadScheduledMessages();
                if (Object.keys(scheduledMessages).length === 0) {
                    await bot.sendMessage(userId, { text: 'Não há mensagens programadas.' });
                    return;
                }

                let messageList = 'Mensagens Programadas:\n\n';
                for (const [messageId, { groupId, messageText, scheduleDate }] of Object.entries(scheduledMessages)) {
                    const groupName = (await bot.groupMetadata(groupId)).subject; // Obter o nome do grupo
                    const formattedDate = moment(scheduleDate).tz('America/Sao_Paulo').format('DD/MM/YYYY HH:mm:ss');
                    messageList += `${messageId} - ${messageText} (Grupo: ${groupName}, Data: ${formattedDate})\n`;
                }

                await bot.sendMessage(userId, { text: messageList });
            } catch (err) {
                console.log('Erro ao visualizar mensagens programadas: ', err);
                await bot.sendMessage(userId, { text: 'Erro ao visualizar mensagens programadas.' });
            }
        }

        async function handleDeleteCommand(userId, messageNumber) {
            try {
                const scheduledMessages = await loadScheduledMessages();
                const messageId = Object.keys(scheduledMessages)[messageNumber - 1]; // Ajuste para 0-index

                if (!messageId) {
                    await bot.sendMessage(userId, { text: 'Número de mensagem inválido.' });
                    return;
                }

                delete scheduledMessages[messageId];
                await saveScheduledMessages(scheduledMessages);
                scheduledJobs[messageId]?.cancel(); // Cancela o job se existir
                delete scheduledJobs[messageId]; // Remove o job agendado

                await bot.sendMessage(userId, { text: 'Mensagem programada excluída com sucesso.' });
            } catch (err) {
                console.log('Erro ao excluir mensagem programada: ', err);
                await bot.sendMessage(userId, { text: 'Erro ao excluir mensagem programada.' });
            }
        }

        async function handleInfoCommand(userId) {
            const uptime = moment.duration(moment().diff(startTime)).humanize();
            const infoMessage = `
┏ 📊 *Informações do Bot*
┃ 
┃ 🤖 *Nome*: ${bot.user.id}
┃ ⏰ *Uptime*: ${uptime}
┃ 📅 *Data de Conexão*: ${startTime.format('DD/MM/YYYY HH:mm:ss')}
┗━━━━━━━━━━
            `;
            await bot.sendMessage(userId, { text: infoMessage });
        }

        bot.ev.on("connection.update", async (update) => {
            const { connection, lastDisconnect, qr } = update;

            if (qr && !qrShown) {
                qrShown = true;
                qrcode.generate(qr, { small: true }, (qrCode) => {
                    console.clear();
                    console.log("\nEscaneie o QR Code para conectar:\n");
                    console.log(qrCode);
                });
            }

            if (connection === "open") {
                console.clear();
                console.log('Conexão estabelecida com sucesso!');

                await reScheduleMessages(); // Chama a função para reprogramar mensagens

                const caption = 
`┏ 📱 *WhatsApp Conectado!*
┃ 🔌 *Modo Operante*: ⚡ ON
┃ 🌐 *Status*: 🟢 Online
┃ 📈 *Sincronização*: 🔄 Ativa
┃ 
┃ 🤖 *Conectado com  Bot Pro*
┃   
┃   Digite /menu
┃ _Criado por: Andre_
┗━━━━━━━━━━
                `;

                const imagePath = './8941b4fd1d316e489028db8c867c7099.jpg';
                const imageBuffer = fs.readFileSync(imagePath);
                await bot.sendMessage(bot.user.id, { image: imageBuffer, caption: caption });
                console.log('Mensagem enviada para o próprio número!');
            }

            if (connection === "close") {
                const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401;
                if (shouldReconnect) {
                    console.log('Tentando reconectar...');
                    startBot();
                } else {
                    console.log('Erro de autenticação. É necessário escanear o QR Code novamente.');
                    qrShown = false;
                }
            }
        });

        bot.ev.on('messages.upsert', async (messageUpdate) => {
            const message = messageUpdate.messages[0];
            if (message.key.fromMe || message.key.remoteJid === bot.user.id) {

                const command = message.message.conversation?.trim();
                if (command === '/menu') {
                    await sendMenu();
                } else if (command.startsWith('/group')) {
                    await handleGroupCommand(command.split(' ')[1]);
                } else if (command.startsWith('/prog')) {
                    await handleProgCommand(message.key.remoteJid, command.replace('/prog', '').trim());
                } else if (command === '/view') {
                    await handleViewCommand(message.key.remoteJid);
                } else if (command.startsWith('/delete')) {
                    const messageNumber = parseInt(command.split(' ')[1]);
                    await handleDeleteCommand(message.key.remoteJid, messageNumber);
                } else if (command === '/info') {
                    await handleInfoCommand(message.key.remoteJid);
                }
            }
        });

        bot.ev.on('creds.update', saveCreds);
    }

    startBot();

    process.on('uncaughtException', function (err) {
        console.log('Erro capturado: ', err);
    });
})();
