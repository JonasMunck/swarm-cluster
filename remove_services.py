import requests

if __name__ == '__main__':

	req = requests.get('http://192.168.99.101:8500/v1/agent/services')
	print(req.json())

	dat = req.json()
	for key in dat:
		if key != 'consul':
			print(key)
			requests.get('http://192.168.99.101:8500/v1/agent/service/deregister/' + key)
