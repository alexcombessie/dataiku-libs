import os
from dataikuapi import APINodeClient

class LocalAPINodeClient(APINodeClient):
    def __init__(self, service_id):
        self.uri = 'http://127.0.0.1:' + str(os.environ["DKU_APIMAIN_PORT"])
        #self.uri = 'http://localhost:'+str(62901)
        self.service_id = service_id
        super(LocalAPINodeClient, self).__init__(uri=self.uri, service_id=self.service_id)

def merge_two_dicts(x, y):
    z = x.copy()   # start with x's keys and values
    z.update(y)    # modifies z with y's keys and values & returns None
    return(z)
