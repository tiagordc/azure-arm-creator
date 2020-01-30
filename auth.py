import os, re
from flask import request, Response
from base64 import b64decode
from functools import wraps

def is_admin(username, password):
    if username == 'admin' and password == 'password': #YWRtaW46cGFzc3dvcmQ=
        return True

def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
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
    return decorated_function 

def auth_required(resource_client):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            authorization_header = request.headers.get('Authorization')
            if authorization_header:
                resource_group_name = re.search("/([^/]+).*/", request.path, re.DOTALL).group(1)
                resource_group = resource_client.resource_groups.get(resource_group_name)
                encoded_uname_pass = authorization_header.split()[-1]
                decoded_uname_pass = b64decode(encoded_uname_pass)
                username, password = decoded_uname_pass.decode().split(':', 1)
                if is_admin(username, password):
                    return f(*args, **kwargs)
                auth = resource_group.tags['arm-auth']
                if encoded_uname_pass == auth:
                    return f(*args, **kwargs)
                xpto = ''
            resp = Response()
            resp.headers['WWW-Authenticate'] = 'Basic'
            return resp, 401
        return decorated_function
    return decorator
