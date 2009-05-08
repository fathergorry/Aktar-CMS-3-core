
@check_phone[phone]
$result[
^if(^phone.int(0) == 0){$.errors[В телефонном номере должны быть только цифры]}
$.data[$phone]

]

