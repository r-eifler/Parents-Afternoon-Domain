#! /bin/python3

import random
import sys
import argparse

from task import Fact, Task


prop_item_nacessary = 2
prop_activity_with_time_window = 3
max_time_window_size = 3
max_activity_duration = 2
car_capacity = 3

class PATask(Task):

    def __init__(self, num_people, num_activities, num_locations, num_time_units):
        super().__init__('parents_afternoon')

        self.num_people = num_people
        self.num_activities = num_activities
        self.num_locations = num_locations
        self.num_time_units = num_time_units

        self.driver = 'parent'
        self.people = []
        self.items = []
        self.activities = []
        self.locations = []
        self.deliver_items = []

        # PDDL
        self.objects['driver'] = [self.driver]

        self.generate_random_task()

    def add_resource(self):
        levels = ['level' + str(i) for i in range(self.num_time_units + 1)]
        self.objects['level'] = levels

        sum_facts = []
        for i in range(self.num_time_units + 1):
            for j in range(self.num_time_units + 1):
                if i + j > self.num_time_units:
                    break
                sum_facts.append(Fact('sum', ['level' + str(i), 'level' + str(j), 'level' + str(i + j)]))

        succ_facts = []
        for i in range(len(levels) - 1):
            succ_facts.append(Fact('succ', [levels[i + 1], levels[i]]))

        less_facts = []
        for i in range(len(levels)):
            for j in range(i, len(levels)):
                less_facts.append(Fact('lesseq', [levels[i], levels[j]]))

        self.init += sum_facts + succ_facts + less_facts

    def generate_random_task(self,):
        self.people = ['p' + str(i) for i in range(self.num_people)]
        self.objects['people'] = self.people
        self.activities = ['a' + str(i) for i in range(self.num_activities)]
        self.objects['activity'] = self.activities
        self.locations = ['l' + str(i) for i in range(self.num_locations)]
        self.objects['location'] = self.locations

        # time
        self.add_resource()
        self.init.append(Fact('time', ['level0']))

        # parent
        self.init.append(Fact('car-capacity', ['level' + str(car_capacity)]))
        self.init.append(Fact('car-at', [self.locations[0]]))
        self.init.append(Fact('at', [self.driver, self.locations[0]]))
        self.init.append(Fact('free', [self.driver]))

        # init locations people
        for p in self.people:
            loc = self.locations[random.randint(0, self.num_locations - 1)]
            self.init.append(Fact('at', [p, loc]))
            self.init.append(Fact('can-in-car', [p]))
            self.init.append(Fact('free', [p]))

        # activities
        for activity in self.activities:
            self.goals.append(Fact('done', [activity]))
            duration = random.randint(1, max_activity_duration)
            duration_str = 'level' + str(duration)
            activity_location = self.locations[random.randint(1, self.num_locations - 1)]
            person = ([self.driver] + self.people)[random.randint(0, self.num_people)]

            self.init.append(Fact('todo', [activity]))
            self.init.append(Fact('activity-duration', [duration_str, activity]))

            # activities start time
            if 0 == random.randint(0, prop_activity_with_time_window):
                self.init.append(Fact('no-start-time', [activity]))
            else:
                time_window_size = random.randint(0,max_time_window_size)
                start_time = random.randint(1, self.num_time_units - (max(time_window_size,duration)))
                start_time_str = 'level' + str(start_time)
                end_time = 'level' + str(start_time + time_window_size)
                self.init.append(Fact('open_time', [activity, start_time_str]))
                self.init.append(Fact('close_time', [activity, end_time]))

            # item necessary ?
            if 0 == random.randint(0, prop_item_nacessary):
                item = 'item' + str(len(self.items))
                self.items.append(item)
                item_loc = self.locations[random.randint(1, self.num_locations - 1)]
                if item_loc != activity_location:
                    self.init.append(Fact('can-in-car', [item]))
                else:
                    self.deliver_items.append((item, item_loc))
                self.init.append(Fact('at', [item, item_loc]))
                self.init.append(Fact('free', [item]))
                self.init.append(Fact('activity-info-o', [person, activity_location, item, activity]))
            else:
                self.init.append(Fact('activity-info', [person, activity_location, activity]))

        if len(self.items) > 0:
            self.objects['load'] = self.items
        for item, source_loc in self.deliver_items:
            target_loc = self.locations[random.randint(0, self.num_locations - 1)]
            while source_loc == target_loc:
                target_loc = self.locations[random.randint(0, self.num_locations - 1)]
            self.goals.append(Fact('at', [item, target_loc]))


if __name__ == "__main__":

    parser = argparse.ArgumentParser(prog='ParentsAfternoonGenerator',
        description='Generate random instances of the Parent\'s Afternoon Domain\n \
            Number of people activities locations and time units can be specified.')
    
    parser.add_argument('-p', dest='num_people', type=int,  help='Number of people in addition to the parent/driver', required=True)
    parser.add_argument('-a', dest='num_activities', type=int, help='number of activities', required=True)
    parser.add_argument('-l', dest='num_locs', type=int, help="Number of locations", required=True)
    parser.add_argument('-t', dest='num_time_units', type=int, help="Number of time units that are covert", required=True)
    parser.add_argument('-seed', dest='seed', default=0, help="Seed for random generator. (default 0)") 

    args = parser.parse_args()

    random.seed(args.seed)

    problem_name = '_'.join(str(a) for a in [args.seed, args.num_people, args.num_activities, args.num_locs, args.num_time_units])
    pa_task = PATask(args.num_people, args.num_activities, args.num_locs, args.num_time_units)

    pa_task.to_PDDL(problem_name, sys.stdout)
