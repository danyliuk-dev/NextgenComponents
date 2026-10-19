"""Exercise the running local, synthetic grouped-inventory endpoint."""
import json
from urllib.request import Request, urlopen
from urllib.error import HTTPError
BASE='http://127.0.0.1:5180/api/grouped-inventory'
def post(*,page=1,size=5,search='',sorts=None,keys=None,flags='',expected=200):
    payload={'page':page,'pageSize':size,'search':search,'sorts':sorts or [],'groupKeys':keys if keys is not None else ['name','availability']}
    request=Request(BASE+flags,data=json.dumps(payload).encode(),headers={'Content-Type':'application/json','Origin':'http://127.0.0.1:5181'},method='POST')
    try:response=urlopen(request,timeout=10)
    except HTTPError as error:response=error
    with response:
        assert response.status==expected,(response.status,expected)
        if expected!=200:return None
        assert response.headers['Access-Control-Allow-Origin']=='http://127.0.0.1:5181'
        return json.load(response)
first=post()
assert first['total']==40 and len(first['items'])==5
assert first['groups'][0]['count']==20 and first['groups'][0]['summaries'][0]['value']==1600
assert first['groups'][1]['count']==12 and first['groups'][1]['summaries'][1]['value']==48
assert [r['item']['id'] for r in first['items']]==['p1','p3','p5','p7','p9']
boundary=post(page=3)
assert [g['path'] for g in boundary['groups']]==[['Chair'],['Chair','Available'],['Chair','Protected']]
filtered=post(search='Desk',sorts=[{'key':'count','descending':True}])
assert filtered['total']==20 and filtered['items'][0]['item']['count']==160
assert filtered['groups'][0]['summaries'][1]['value']==84
assert filtered['groups'][1]['path']==['Desk','Protected']
assert filtered['groups'][1]['summaries'][0]['value']==1056
one=post(keys=['name'])
assert len(one['groups'])==1 and one['items'][0]['path']==['Chair']
empty=post(search='missing')
assert empty=={'items':[],'total':0,'groups':[]}
shrunk=post(page=8,flags='?small=true')
assert shrunk=={'items':[],'total':7,'groups':[]}
last=post(page=2,flags='?small=true')
assert len(last['items'])==2 and last['total']==7
post(flags='?fail=true',expected=503)
malformed=post(flags='?malformed=true')
assert malformed['groups'][0]['count']==0
post(keys=['unknown'],expected=400)
post(keys=['name','name'],expected=400)
post(size=51,expected=400)
post(keys=[],expected=400)
print('PASS 13 HTTP grouped API scenarios: counts, summaries, boundary paths, sorting, search, depth, empty, shrink, failure, malformed fixture and invalid requests')
