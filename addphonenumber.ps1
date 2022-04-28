$user=$args[0]
$number=$args[1]
Set-CsPhoneNumberAssignment -Identity $user -PhoneNumber $number -PhoneNumberType CallingPlan -LocationId 44f1f3bf-6452-4250-b4a6-b2d03eaffd9d