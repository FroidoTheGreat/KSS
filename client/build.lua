local s = require('network_settings')

os.execute("git ls-files | zip project.zip -@")
os.execute("scp project.zip root@"..s.server_ip..":/root/")
os.execute("rm project.zip")