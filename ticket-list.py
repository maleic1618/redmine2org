from redminelib import Redmine
from secretkey import *
import unicodedata

def get_char_width(c):
    data = unicodedata.east_asian_width(c)
    if data == 'Na' or data == 'H':
        return 1
    return 2

def get_string_width(string):
    width = 0
    for c in string:
        width += get_char_width(c)
    return width

def multibyte_str_align(string, length):
    num = get_string_width(string)
    if num>=length:
        return string
    else:
        return (' ' * (length-num)) + string

redmine = Redmine(REDMINE_URL, key=API_KEY)
issue_itr = redmine.issue.filter(status='完了')
ticket_str = '#{id:0>4} | {status} | {subject}\n'
output = 'ID    | status | subject\n'

for issue in issue_itr:
    output += ticket_str.format(id=issue.id, status=multibyte_str_align(str(issue.status), 6), subject=issue.subject)

print(output)    

