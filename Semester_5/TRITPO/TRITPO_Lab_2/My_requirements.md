# ���������� � �������
---

# ����������
1 [��������](#intro)  
1.1 [����������](#appointment)  
1.2 [������-����������](#business_requirements)  
1.2.1 [�������� ������](#initial_data)  
1.2.2 [����������� �������](#business_opportunities)  
1.2.3 [������� �������](#project_boundary)  
1.3 [�������](#analogues)  
2 [���������� ������������](#user_requirements)  
2.1 [����������� ����������](#software_interfaces)  
2.2 [��������� ������������](#user_interface)  
2.3 [�������������� �������������](#user_specifications)  
2.3.1 [������ �������������](#user_classes)  
2.3.2 [��������� ����������](#application_audience)  
2.3.2.1 [������� ���������](#target_audience)  
2.3.2.1 [�������� ���������](#collateral_audience)  
2.4 [������������� � �����������](#assumptions_and_dependencies)  
3 [��������� ����������](#system_requirements)  
3.1 [�������������� ����������](#functional_requirements)  
3.1.1 [�������� �������](#main_functions)  
3.1.1.1 [���� ������������ � ����������](#user_logon_to_the_application)  
3.1.1.2 [��������� ������� ��������� ������������](#setting_up_the_profile_of_the_active_user)  
3.1.1.3 [�������� ��������](#download_news)  
3.1.1.4 [�������� ���������� �� ��������� �������](#view_information_about_an_individual_newsletter)  
3.1.1.5 [����� ������������ �� ������� ������](#active_user_change)  
3.1.1.6 [����������� ������ ������������ ����� ����� � ����������](#add_new_user)  
3.1.2 [����������� � ����������](#restrictions_and_exclusions)  
3.2 [���������������� ����������](#non-functional_requirements)  
3.2.1 [�������� ��������](#quality_attributes)  
3.2.1.1 [���������� � �������� �������������](#requirements_for_ease_of_use)  
3.2.1.2 [���������� � ������������](#security_requirements)  
3.2.2 [������� ����������](#external_interfaces)  
3.2.3 [�����������](#restrictions)  

<a name="intro"/>

# 1 ��������

<a name="appointment"/>

## 1.1 ����������
� ���� ��������� ������� �������������� � ���������������� ���������� � ������������ ���������� ���� �������-���������� "In the trenches" ��� ��������� ��. 
���� �������� ������������ ��� �������, ������� ����� ������������� � ��������� ������������ ������ ����������. 

<a name="business_requirements"/>

## 1.2 ������-����������

<a name="initial_data"/>

### 1.2.1 �������� ������
������ ����� ������������ ������� ���������, � ���������� ����� ���������� �� 1� � 2� ������� �����. �������� ��������� ������ ���������� � ������, ������������� � �� ������. ������ ������� ������������� ���� �����������, � �������� ���������� ������� �������� ���������� ��� ������ �����, � ���� �� ���������� ����������. ��������� ����� ���� ����� �� � ���� ��� ������, ��� ��� �� ����, ����������� � �������� ����. 

<a name="business_opportunities"/>

### 1.2.2 ����������� �������
����� ���������������� ��������� ��������� � ����������� ��������, ������� � ������ ������� ������ ������ ��������������� � ���� �����.  
������ ����� ��������� ����������� �������� ���������� �������������. 
���������� �������� ��������� �� ����� ����������� ������, � ������ ����������� ������ � ������ ������ ��� ������ ������� ��� � ������.
������� ����������� ���������� ������������� ��������� �������� ������������ ������ ����������� ���.

<a name="project_boundary"/>

### 1.2.3 ������� �������
������ � ������ ���� ��������������� ������ ����� �����������. ��� ���������������� ������������� �������� ������� ���� � ��������-������. 

<a name="analogues"/>

## 1.3 �������
����� �������� ����������� � ��������� [Overview_of_analogues](./Requirements/Overview_of_analogues.md).

<a name="user_requirements"/>

# 2 ���������� ������������

<a name="software_interfaces"/>

## 2.1 ����������� ����������
���������� ������������ RSS-����� ��������-��������, ��������������� ���������� RSS 1.0 � 2.0. 

<a name="user_interface"/>

## 2.2 ��������� ������������
���� ����� � ����������.  
![���� ����� � ����������](../../Images/Mockups/ApplicationLoginWindow.PNG)  
���� ����������� ������ ������������.  
![���� ����������� ������ ������������](../../Images/Mockups/RegistrationWindow1.PNG)  
���� ����������� ������ ������������ ����� ����� �����, ��� ������������������� � ����������.  
![���� ����������� ������ ������������ ����� ����� �����, ��� ������������������� � ����������](../../Images/Mockups/RegistrationWindow2.PNG)  
���� ����� ��� ������������������� ������������.  
![���� ����� ��� ������������������� ������������](../../Images/Mockups/LoginScreenForTheRegisteredUser.PNG)  
������� ���� ���������� (������������ ���������������).  
![������� ���� ����������](../../Images/Mockups/MainWindow1.PNG)  
������� ���� ���������� ����� ������ ������� � ������� (������������ ���������������).  
![������� ���� ���������� ����� ������ ������� � �������](../../Images/Mockups/MainWindow2.PNG)  
������� ���� ���������� ����� ������ ������� � ������� (��������� ������������).  
![������� ���� ���������� ����� ������ ������� � �������](../../Images/Mockups/MainWindowAnonymousUser.PNG)  
���� ��������� ������� ������������.  
![���� ��������� ������� ������������](../../Images/Mockups/SettingUpAUserProfile.PNG)

<a name="user_specifications"/>

## 2.3 �������������� �������������

<a name="user_classes"/>

### 2.3.1 ������ �������������

| ����� ������������� | �������� |
|:---|:---|
| ��������� ������������ | ������������, ������� �� ����� ���������������� � ����������. ����� ������ � ���������� ����������� |
| ������������������ ������������ | ������������, ������� ����� � ���������� ��� ����� ������ (�����������), �������� ������������� ������� ���������� � ��������, ���������� �������� �� �������������. ����� ������ � ������� ����������� |

<a name="application_audience"/>

### 2.3.2 ��������� ����������

<a name="target_audience"/>

#### 2.3.2.1 ������� ���������
���� ������� ���������� ��������� �� ������� ��� ���� �������� ������� �����������, ���������� ����������� ����������� ������������.

<a name="collateral_audience"/>

#### 2.3.2.2 �������� ���������
���� ������� ���������� ���������, ���������� ������������������ ����������.

<a name="assumptions_and_dependencies"/>

## 2.4 ������������� � �����������
1. ���������� �� �������� ��� ���������� ����������� � ���������;
2. ���������� �� ������������ ������ RSS-����, ����������� � ������ �������.

<a name="system_requirements"/>

# 3 ��������� ����������

<a name="functional_requirements"/>

## 3.1 �������������� ����������

<a name="main_functions"/>

### 3.1.1 �������� �������

<a name="user_logon_to_the_application"/>

#### 3.1.1.1 ���� ������������ � ����������
**��������.** ������������ ����� ����������� ������������ ���������� ��� �������� ������������ ������� ���� ����� � ���� ������� ������.

| ������� | ���������� | 
|:---|:---|
| ���� � ���������� ��� �������� ������������ ������� | ���������� ������ ������������ ������������ ����������� ����� � ���������� �������� |
| <a name="registration_requirements"/>����������� ������ ������������ | ���������� ������ ��������� � ������������ ������ ��� ��� �������� ������� ������. ������������ ������ ���� ������ ���, ���� �������� �������� |
| *������������ � ����� ������ ����������* | *���������� ������ ��������� ������������ �� ������ ����������� � ��������� ���� ����������. ������������ ������ ���� ������ ���������, ���� �������� ��������* |
| ���� ������������������� ������������ � ���������� | ���������� ������ ������������ ������������ ������ ��� (�����������) ������������������ �������������. ������������ ������ ���� ������� �� ������ ��� ��� (���������), ���� �������� �������� |

<a name="setting_up_the_profile_of_the_active_user"/>

#### 3.1.1.2 ��������� ������� ��������� ������������
**��������.** ������������������ ������������ ����� ����������� ������������� ������ ������ �� ��������-�������, � ������� ������������ ������� ��������, � ������ (��������� � ����������) �������� ���� ��� ���������� ��������.
 
| ������� | ���������� | 
|:---|:---|
| ���������� ��������-�������� | ���������� ������ ������������ ������������������� ������������ ���� ��� ����� ������ RSS-����� ��������-�������. ������������ ������ ���� ������ ����� � ���������� ��������, ���� �������� ��� |
| �������� ��������-�������� | ������������������ ������������ ����� �������������� �������� ����� RSS-����� � ������ ��������-�������� � ������� ��� |
| ���������� �������� ���� | ���������� ������ ������������ ������������������� ������������ ����������� ������� ������, � ������� ����� ��������� �����, � ���� ��� � �����. ����� ������ ������ ������������ ������ ���� ������ ����� � ���������� ��������, ���� �������� ��� |
| �������� �������� ���� | ������������������ ������������ ����� ����������� �������� �������� ����� � ����� �� ������� � ������� � |

<a name="download_news"/>

#### 3.1.1.3 �������� ��������
**��������.** ����� ����� ������������ � ���������� ��� ����� ���������� �������������� ������� ������������������ ������������� ���������� ��������� ���������� � �������� � ������������� �� �������� ������� �������� ����.

| ������� | ���������� | 
|:---|:---|
| �������� ���������� � �������� | ���������� ������ ��������� ���������� � �������� � ��������-�������� ����� ����� ������������ � ���������� ��� ����� ���������� �������������� ������� ������������������ ������������� |
| ���������� �������� | ���������� ������ ������������� ������� �������� ������� �������� ���� |

<a name="view_information_about_an_individual_newsletter"/>

#### 3.1.1.4 �������� ���������� �� ��������� �������
**��������.** ������������ ����� ����������� ����������� ���������� � ������ �������, �������������� � �������.

| ������� | ���������� | 
|:---|:---|
| �������� ������� ���������� | ������������ ����� ����������� ������� ������� � ������� ��������� ������ �� ���. ���������� ������ ���������� � ���������, �������� � ���� ���������� "���������" �������� ���� ���������� |
| �������� ��������� ���������� | ������������ ����� ����������� ������� ������� � ������� ������� ������ �� ���. ���������� ������ ������� ������ ������ �������� � ��������, ������������� � ������� �� ��������� |

<a name="active_user_change"/>

#### 3.1.1.5 ����� ������������������� ������������ �� ������� ������
**��������.** ������������������ ������������ ����� ����������� ����� �� ������� ������.

**����������.** ���������� ������ ������������ ������������������� ������������ ����������� ����� �� ������� ������ � ��������� � ���� ����� � ����������.

<a name="add_new_user"/>

#### 3.1.1.6 ����������� ������ ������������ ����� ����� � ����������
**��������.** ��������� ������������ ����� ����������� ������������������ � ����������.

**����������.** ���������� ������ ������������ ���������� ������������ ����������� [������������������ � ����������](#registration_requirements). 

<a name="restrictions_and_exclusions"/>

### 3.1.2 ����������� � ����������
1. ���������� �������� ������ ��� ������� ����������� � ���������;
2. ������������ �������� ��������-������� �������������� ��� ������� � ���������� RSS-�����. 

<a name="non-functional_requirements"/>

## 3.2 ���������������� ����������

<a name="quality_attributes"/>

### 3.2.1 �������� ��������

<a name="requirements_for_ease_of_use"/>

#### 3.2.1.1 ���������� � �������� �������������
1. ������ � �������� �������� ���������� �� ����� ��� �� ��� ��������;
2. ��� �������������� �������� ����������������� ���������� ����� ��������, ����������� ��������, ������� ���������� ��� ������ ��������;
3. ��������� ���������� ������������� �������� ������� ���������� ���������� � �������;
4. ���������� ���������� � �������� ���������� ������ 15 ����� � ������� ������.

<a name="security_requirements"/>

#### 3.2.1.2 ���������� � ������������
���������� ������������� ����������� ��������� � �������������� ������� ������ ��������� ������������.

<a name="external_interfaces"/>

### 3.2.2 ������� ����������
���� ���������� ������ ��� ������������� �������������� � ������ �������:
  * ������ ������ �� ����� 14��;
  * �������������� �������� ���������� ���� ����.

<a name="restrictions"/>

### 3.2.3 �����������
1. ���������� ����������� �� ��������� .NET Framework 4.6;
2. ������� ������������ �������� � ����� � ����������� XML, �������� ����� ��������� � ������ (�����������).