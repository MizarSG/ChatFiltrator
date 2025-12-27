# ChatFiltrator

ChatFiltrator is a lightweight World of Warcraft Classic addon that filters chat messages using configurable keyword rules and routes matching messages into a separate chat window with optional notifications.

It is designed to work reliably in Classic Era including during first login and UI reloads.

## Features
- Filters chat messages using include and exclude keyword lists
- All include words must match; any exclude word blocks the message
- Separate chat window for matched messages
- Optional notifications:
-- Sound alert
-- Screen flash
-- On-screen text notification
- Settings saved between sessions
- Slash-command configuration (no reload required)
- Classic-safe initialization and chat handling

## Slash Commands
/cf notify  - Toggle notifications  
/cf status - Shows current settings
/cf add include <word> - Adding include word
/cf remove include <word> - Removing include work
/cf add exclude <word> - Adding exclude word
/cf remove exclude <word> - Removing exclude work

## Configuration
- Notifications
- Include words
- Exclude words

## Supported Versions
- Classic Era

## License
MIT