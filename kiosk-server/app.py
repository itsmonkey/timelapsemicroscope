from flask import Flask, send_from_directory, request
from flask import render_template

import subprocess
import os

app = Flask(__name__, static_folder='static')

@app.route('/')
def index():
    return send_from_directory('static', 'index.html')

@app.route('/api/mode/<mode>', methods=['POST'])
def set_mode(mode):
    valid = ['video', 'stream', 'camera', 'ha', 'klipper']
    if mode not in valid:
        return {'status': 'error', 'message': 'invalid mode'}, 400

    # Write mode to file
    with open('/home/michael/current_mode.txt', 'w') as f:
        f.write(mode)

    # Reload kiosk
    subprocess.Popen(['/home/michael/kiosk-reload.sh'])

    return {'status': 'ok', 'mode': mode}

@app.route('/static/<path:path>')
def static_files(path):
    return send_from_directory('static', path)

@app.route('/camera')
def camera_page():
    return render_template('camera.html')


@app.route('/camera/start')
def camera_start():
    subprocess.Popen([
        "/usr/local/bin/mjpg_streamer",
        "-i", "/usr/local/lib/mjpg-streamer/input_uvc.so -d /dev/video0 -r 640x480 -f 15",
        "-o", "/usr/local/lib/mjpg-streamer/output_http.so -p 8080 -l 0.0.0.0 -w /usr/local/share/mjpg-streamer/www"
    ])
    return "OK"














@app.route('/camera/stop')
def camera_stop():
    subprocess.call(["pkill", "mjpg_streamer"])
    return "OK"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
