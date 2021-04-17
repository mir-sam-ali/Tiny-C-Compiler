

int n = 10;

int arr[10];

for (int i = 0; i < n; i++)
{
    arr[i] = 20 - (2 * i);
}

int i, key, j;
for (i = 1; i < n; i++)
{
    key = arr[i];
    j = i - 1;

    /* Move elements of arr[0..i-1], that are
        greater than key, to one position ahead
        of their current position */
    while (j >= 0 && arr[j] > key)
    {
        int k = j + 1;
        arr[k] = arr[j];
        j = j - 1;
    }
    int k = j + 1;
    arr[k] = key;
}

print("Sorted Array\n");
for (i = 0; i < n; i++)
{
    print(arr[i], "\n");
}