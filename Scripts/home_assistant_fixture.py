from http.server import BaseHTTPRequestHandler,ThreadingHTTPServer
import json
records=[]
class H(BaseHTTPRequestHandler):
 def log_message(self,*a):pass
 def reply(self,status,data):
  self.send_response(status);self.send_header('Content-Type','application/json');self.end_headers();self.wfile.write(json.dumps(data).encode())
 def do_GET(self):
  if self.path=='/records':return self.reply(200,records)
  if self.path=='/api/':return self.reply(200,{'message':'API running.'})
  if self.path=='/api/states':return self.reply(200,[{'entity_id':eid,'state':'off','attributes':{'friendly_name':name},'tt_area':area,'tt_device':device} for eid,name,area,device in [('light.desk','Desk','Office','Desk lamp'),('scene.evening','Evening','Living room',''),('automation.evening','Evening automation','Living room',''),('sensor.weather','Weather','Outside','')]])
  if self.path=='/api/services':return self.reply(200,[{'domain':d,'services':{s:{'name':s.replace('_',' ').capitalize(),'target':{},'fields':({'brightness_pct':{'required':True}} if s=='set_level' else {})} for s in ss}} for d,ss in [('light',['toggle','turn_on','turn_off','set_level']),('scene',['turn_on']),('automation',['trigger'])]])
  return self.reply(404,{})
 def do_POST(self):
  raw=self.rfile.read(int(self.headers.get('Content-Length','0')))
  if self.path=='/auth/token':return self.reply(200,{'access_token':'fixture-token','refresh_token':'fixture-refresh','expires_in':1800})
  records.append({'path':self.path,'body':json.loads(raw)})
  self.reply(200,[])
ThreadingHTTPServer(('0.0.0.0',18123),H).serve_forever()
