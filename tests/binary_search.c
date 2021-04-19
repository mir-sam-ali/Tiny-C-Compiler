int arr[10];
for (int i = 0; i < 10; i++)
{
    arr[i] = (i + 1) * 5;
}

int l = 0, r = 9;
int x = 20;
int index = -1;
while (l <= r)
{
    int m = l + (r - l) / 2;

    // Check if x is present at mid
    if (arr[m] == x)
    {
        index = m;
        break;
    }

    // If x greater, ignore left half
    if (arr[m] < x)
        l = m + 1;

    // If x is smaller, ignore right half
    else
        r = m - 1;
}

if (index == -1)
{
    print(x, " Not Found\n");
}
else
{
    print("Index: ");
    print(index);
    print("\n");
}
