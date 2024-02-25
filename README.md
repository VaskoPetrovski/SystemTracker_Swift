# SystemTracker Plugin

The SystemTracker Plugin is a  plugin designed for Unity developers to monitor and analyze the performance of their application. It provides detailed insights into CPU and memory usage.

### Prerequisites
  - Unity 2019.4 LTS or newer 
  -  iOS project deployment target 12.0 or higher

### Installation

1. Clone the repository or download the source code. 
2. Build the source to create a `.framework` file. 
3.  Add the `.framework` file to your Unity project by following this path: `Assets/Plugins/iOS/your_framework_name.framework`

### Usage

1. Ensure the framework is added to your Unity project. 
2. Use the code snippet below to instantiate and invoke the plugin from a UI element, such as a button.
## Example

```csharp
  
using UnityEngine;  
using System.Runtime.InteropServices;  
  
public class ButtonControllerScript : MonoBehaviour  
{  
    [DllImport("__Internal")]  
    private static extern void startSwiftCodeKitController();  
  
    public void OnPressButton()  
    {  
        startSwiftCodeKitController();  
    }  
}
```

### Tested with:
- Xcode 15
- Unity 2021/2022