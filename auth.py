from flask import request, Response
from base64 import b64decode
from functools import wraps

def is_admin(username, password):
    if username == 'admin' and password == 'password':
        return True

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        authorization_header = request.headers.get('Authorization')
        if authorization_header:
            encoded_uname_pass = authorization_header.split()[-1]
            decoded_uname_pass = b64decode(encoded_uname_pass)
            username, password = decoded_uname_pass.decode().split(':', 1)
            if is_admin(username, password):
                return f(*args, **kwargs)
        resp = Response()
        resp.headers['WWW-Authenticate'] = 'Basic'
        return resp, 401
    return decorated        

def auth_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        authorization_header = request.headers.get('Authorization')
        if authorization_header:
            encoded_uname_pass = authorization_header.split()[-1]
            decoded_uname_pass = b64decode(encoded_uname_pass)
            username, password = decoded_uname_pass.decode().split(':', 1)
            if is_admin(username, password):
                return f(*args, **kwargs)
        resp = Response()
        resp.headers['WWW-Authenticate'] = 'Basic'
        return resp, 401
    return decorated
