char arr[5];

arr[0] = 'b';
arr[1] = 'c';
arr[2] = 'd';
arr[3] = 'a';
arr[4] = 'e';

for (int i = 0; i < 4; i = i + 1)
{
    for (int j = 1; j < 5 - i; j = j + 1)
    {
        int k = j + 1;
        if (arr[j] > arr[k])
        {
            char temp = arr[j];
            arr[j] = arr[k];
            arr[k] = temp;
        }
    }
}

for (int i = 0; i < 5; i++)
{
    print(arr[i], " ");
}
print("\n");
