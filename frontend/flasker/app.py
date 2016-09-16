from flask import Flask
from flask import request
from flask import abort

import os
import socket
app = Flask(__name__)



@app.route('/')
def hello():
    """
    Serves a very simple web page on port 5000

    Shows the

        CONTAINER ID for the container this application is running on
        
        and 

        the COLOR label - just a tag for grouping services.


    Example
    =======

    `Hello World from bac69d1b97ae This is the green color.`

    """
    return 'Hello World from %s\nThis is the %s color.\n' % (socket.gethostname(), os.environ.get('SERVICE_COLOR'))


    # return 'New FEATURE!!!\n\nUpdated %s!\n\n<br/>This is the %s color.\n' % (socket.gethostname(), os.environ.get('SERVICE_COLOR'))





























    # uncomment to update
    # then run
    #   cd /Users/JonasMunck/programming/consul-lek/frontend/flasker
    #   docker build -t jonasmunck/flasker .
    #   docker push jonasmunck/flasker 
    # make sure you are on swarm master
    #   cd /Users/JonasMunck/programming/consul-lek/frontend
    #   docker-compose stop flask-blue && docker-compose rm flask-blue
    #   docker-compose pull flask-blue
    #   docker-compose create --force-recreate flask-blue  
    #   docker-compose up -d --force-recreate flask-blue
    

    #   docker-compose stop flask-green && docker-compose rm flask-green
    #   docker-compose pull flask-green
    #   docker-compose create --force-recreate flask-green
    #   docker-compose up -d --force-recreate flask-green


@app.route('/toggle-health')
def toggle_health():    
    status = request.args.get('status')
    if status == 'up':
        with open("hello.txt", "w") as f:
            f.write("up")
        return 'up and running'

    with open("hello.txt", "w") as f:
            f.write("down")
    return 'container is down'


@app.route('/status')
def status():
    with open("hello.txt", "r") as f:
        data = f.readlines()
        for line in data:
            status = line.split()[0]
            if status == 'down':
                return  abort(500)
            return 'status ' + str(status)


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
