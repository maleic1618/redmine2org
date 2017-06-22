import sys
from redminelib import Redmine
from secretkey import *

argv_list = sys.argv

if len(argv_list)>=3:
    print("argument must be only one.")
    exit()

redmine = Redmine(REDMINE_URL, key=API_KEY)
issue = redmine.issue.get(argv_list[1])

ticket_str = """#{id}: {subject}

================================================
- ステータス | {status}
- 進捗率     | {done_ratio}% 
- 担当者     | {assigned_to}

説明:
  {description}

================================================
コメント:
{journals}"""

journal_str = """------------------------------------------------
{time}: {user}{info}
  {note}
"""

info_tmp = ""
tmp = ""
output = ""

for jour in issue.journals:
    info_tmp = ""
    for detail in jour.details:
        if 'name' in detail.keys(): continue
        if detail['name'] in ['done_ratio', 'subject']:
          info_tmp += "\n[ {0} を {1} から {2} へ変更 ]".format(detail['name'], detail['old_value'], detail['new_value'])
    tmp += journal_str.format(user=jour.user, time=jour.created_on, note=jour.notes.replace('\r', '').replace('\n', '\n  '), info=info_tmp)

if 'assigned_to' in dir(issue):
    person_in_charge = issue.assigned_to
else:
    person_in_charge = 'なし'
    
output += ticket_str.format(id=issue.id, subject=issue.subject, status=issue.status,
                            description=issue.description.replace('\r', '').replace('\n', '\n  '), url=issue.url, journals=tmp,
                            done_ratio=issue.done_ratio, assigned_to=person_in_charge)

print(output)
