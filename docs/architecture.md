\# Architecture - IAM Least Privilege Lab



\## High-Level Architecture



```text

+------------------------------------------------------+

| AWS Account - NovaCloud Analytics Lab                |

|                                                      |

|  +------------------------------------------------+  |

|  | IAM User                                       |  |

|  | terraform-lab-admin                            |  |

|  +----------------------+-------------------------+  |

|                         |                            |

|                         | sts:AssumeRole             |

|                         v                            |

|  +------------------------------------------------+  |

|  | IAM Role                                       |

|  | novacloud-iam-lab-dev-data-analyst-readonly    |

|  +----------------------+-------------------------+  |

|                         |                            |

|                         | s3:ListBucket              |

|                         | s3:GetObject               |

|                         v                            |

|  +------------------------------------------------+  |

|  | S3 Data Bucket                                 |

|  | novacloud-iam-lab-dev-606895006811             |

|  |                                                |

|  | reports/                                       |

|  |   sample-report.txt                            |

|  |                                                |

|  | evidence/                                      |

|  |   internal-evidence.txt                        |

|  +------------------------------------------------+  |

|                                                      |

+------------------------------------------------------+

