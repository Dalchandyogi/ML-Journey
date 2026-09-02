# -------------- list [changeable] ---------

marks = [100, 89, 90, 90, 89]

print(marks.count(90)) # count the occurrences
print(len(marks))
marks.sort(reverse=True) # sort the element descending order
print(marks)
marks.append(100) # append element at the end
print(marks)
print(type(marks))


# ------------ Tuples (Unchangeable)---------

cars = ("car1", "car2", "car3", "car1")

print(cars.count('car1'))
print(len(cars))

# -------- Set {unordered, unchangeable*, and unindexed. No duplicate members.} -------------
# *Set items are unchangeable, but you can remove items and add new items.

myset = {"apple", "banana", "cherry"}
myset.add("new")
print(myset)
myset.remove("new") # If the item to remove does not exist, remove() will raise an error.
print(myset)

myset.discard("new") #  If the item to remove does not exist, discard() will NOT raise an error.
print(myset)

# ------ dictionary { ordered** and changeable. No duplicate members.} -------------

student = {
    "name" : 'Dal chand Yogi',
    "class": 'MCA',
    "skill" : ['Python', 'Mobile Application Development']
}

print(student['skill'])

student['interest'] = ['Music', 'Dance', 'Politics']

print(student)


# ---------------------------------------- Functions --------------------------------------------------------------------------------

def calculate_mean(l):
    count = 0
    add = 0

    for item in l:
        count += 1
        add += item
    mean = add/count

    return mean

l1 = [1,2,3]
print(f'Mean : {calculate_mean(l1)}')


def calculate_max(l):
    maxx = l[0]

    for i in range(0, len(l)):
        if l[i] > maxx:
            maxx = l[i]
    return maxx


print(f"Max from List : {calculate_max(l1)}")

def calculate_min(l):
    maxx = l[0]

    for i in range(0, len(l)):
        if l[i] < maxx:
            maxx = l[i]
    return maxx

print(f"MIN from List : {calculate_min(l1)}")


# -----------  *args / **kwargs ----------------------------------------------------------------------------------------

# Using *args to accept any number of arguments
def calculate_average(*args):
    count = 0
    total = 0
    for item in args :
        count += 1
        total = total + item

    avg = total/count

    return avg

print(f"AVG : {calculate_average(3,2,4)}")

#  Using **kwargs to accept any number of keyword arguments

def show_model_config(**kwargs):

    print("=" * 40)
    print(" MODEL CONFIGURATION")
    print("=" * 40)

    if "model" in kwargs:
        print(f"{'Model Type':<20}: {kwargs.pop('model')}")
        print("-" * 40)

    for key, value in kwargs.items():
        # Replaces underscores with spaces and capitalizes words for clean display
        formatted_key = key.replace("_", " ").title()
        print(f"{formatted_key:<20}: {value}")

    print("=" * 40)

show_model_config(model="RandomForest", n_estimators=100, max_depth=10, random_state=42)


# ----------------------------------------  Comprehensions -----------------------------------------------------------

numbers = list(range(1, 21))

squares = [x**2 for x in numbers]
even_nums = [x for x in numbers if x%2 == 0]
odd_numbers = [x for x in numbers if x % 2 != 0]

print(f"Numbers : {numbers}")
print(f"Squares : {squares}")
print(f"Even : {even_nums}")
print(f"Odd : {odd_numbers}")


# ----------------------------------------  Generator --------------------------------------------------
def batch_generator(data, batch_size):
    start = 0
    stop = len(data)
    step = batch_size

    for i in range(start, stop, step):
        yield data[i : i + batch_size]

# Testing the function
d = list(range(1, 21))
b_size = 5

for batch in batch_generator(d, b_size):
    print(batch)


# ------------------------  Exception Handling  ---------------------------

def safe_int_converter(user_input):
    try:
        return int(user_input)
    except (ValueError, TypeError):
        return "Cannot Converted."

a = input("Enter : ")

print(f'Before Type : {type(a)}')

a_int = safe_int_converter(a)
print(f"After : {type(a_int)}")

