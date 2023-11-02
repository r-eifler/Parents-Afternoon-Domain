class Fact:

    def __init__(self, predicate: str, args: list[str], negated=False) -> None:
        self.predicate: str = predicate
        self.args: list[str] = [a.lower() for a in args]
        self.negated: bool = negated

    def __str__(self) -> str:
        if self.negated:
            return '! (' + ' '.join([self.predicate] + self.args) + ')'
        return '(' + ' '.join([self.predicate] + self.args) + ')'

    def __eq__(self, other) -> bool:
        return self.predicate == other.predicate and self.args == other.args

    def __hash__(self) -> int:
        return hash(str(self))


class Task:

    def __init__(self, domain_name) -> None:
        self.domain_name: str = domain_name
        self.objects: dict[str, list[str]] = {}
        self.init: list[Fact] = []
        self.goals: list[Fact] = []

    def to_PDDL(self, name: str, stream) -> None:

        # output
        stream.write('(define (problem pa_' + name + ')\n')
        stream.write('(:domain ' + self.domain_name + ')\n')
        stream.write('(:objects\n')
        for type, objs in self.objects.items():
            stream.write('\t' + ' '.join(objs) + ' - ' + type + '\n')
        stream.write(')\n')
        stream.write('(:init\n')
        for fact in self.init:
            stream.write('\t' + str(fact) + '\n')
        stream.write(')\n')
        stream.write('(:goal (and\n')
        for fact in self.goals:
            stream.write('\t' + str(fact) + '\n')
        stream.write('))\n')
        stream.write(')\n')

