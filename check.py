import requests

if __name__ == '__main__':

	payload = {
	  "ID": "mem",
	  "Name": "HTTP Check",
	  "Notes": "Ensure we have healthy service",
	  "DeregisterCriticalServiceAfter": "90m",
	  "HTTP": "192.168.99.104:32779",
	  "Interval": "10s",
	  "TTL": "15s",
	}

	requests.put('http://192.168.99.100:8500/v1/agent/check/register', json=payload)