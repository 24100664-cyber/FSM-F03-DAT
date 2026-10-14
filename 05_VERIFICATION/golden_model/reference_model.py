class F03Model:
    def __init__(self, secret=(1,2,3,4), threshold=3):
        self.secret=tuple(secret)
        self.threshold=threshold
        self.digits=[]
        self.failures=0
        self.locked=False

    def reset(self):
        self.digits=[]
        self.failures=0
        self.locked=False

    def enter_digit(self,d):
        if self.locked:
            return None
        self.digits.append(d)
        if len(self.digits)==4:
            code=tuple(self.digits)
            self.digits=[]
            if code==self.secret:
                self.failures=0
                return "UNLOCK"
            self.failures += 1
            if self.failures>=self.threshold:
                self.locked=True
                return "LOCKED"
            return "WRONG"
        return "DIGIT_ACCEPTED"

def run():
    m=F03Model()
    assert m.enter_digit(1)=="DIGIT_ACCEPTED"
    assert m.enter_digit(2)=="DIGIT_ACCEPTED"
    assert m.enter_digit(3)=="DIGIT_ACCEPTED"
    assert m.enter_digit(4)=="UNLOCK"
    assert m.failures==0

    m=F03Model()
    wrong=(9,9,9,9)
    for i,d in enumerate(wrong):
        m.enter_digit(d)
    assert m.failures==1
    for d in wrong: m.enter_digit(d)
    assert m.failures==2
    for d in wrong: m.enter_digit(d)
    assert m.locked

    m=F03Model()
    for d in (9,9,9,9): m.enter_digit(d)
    for d in (1,2,3,4): m.enter_digit(d)
    assert m.failures==0 and not m.locked

    print("F03 mentor reference PASS")
    print("Default secret = 1,2,3,4; threshold = 3.")
    print("These are mentor defaults, not official F03 values.")

if __name__=="__main__":
    run()
