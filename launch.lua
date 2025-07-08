local num_clients = require('client/network_settings').num_players

os.execute('for i in {1..'..num_clients..'}; do /Applications/love.app/Contents/MacOS/love client & done')