from redminelib import Redmine
from secretkey import *

redmine = Redmine(REDMINE_URL, key=API_KEY)
issue_itr = redmine.issue.filter(status='完了')
ticket_str = """
* {status} #{id}: {subject}
link: {url}
** 説明
   {description}
** コメント{journals}"""
journal_str = """
*** {user}: {time}
    {note}"""

output = "#+TODO: 新規 着手 進行中 確認 | 完了"

for issue in issue_itr:
    tmp = ""
    for jour in issue.journals:
        tmp += journal_str.format(user=jour.user, time=jour.created_on, note=jour.notes.replace('\r', '').replace('\n', '\n    '))
        
    output += ticket_str.format(id=issue.id, subject=issue.subject, status=issue.status,
                                description=issue.description.replace('\r', '').replace('\n', '\n   '), url=issue.url, journals=tmp)

print(output)    
