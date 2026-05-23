GET /v2/cursus/1/projects
200
[
  {
    "id": 1,
    "name": "Libft",
    "slug": "libft",
    "difficulty": 5000,
    "description": "The first project of 42 !",
    "parent": null,
    "children": [],
    "objectives": [
      "initiation"
    ],
    "attachments": [],
    "created_at": "2017-11-22T13:41:25.963Z",
    "updated_at": "2017-11-22T13:41:26.243Z",
    "exam": false,
    "cursus": [
      {
        "id": 1,
        "created_at": "2017-11-22T13:41:00.750Z",
        "name": "Piscine C",
        "slug": "piscine-c"
      }
    ],
    "campus": [
      {
        "id": 1,
        "name": "Cluj",
        "time_zone": "Europe/Bucharest",
        "language": {
          "id": 3,
          "name": "Romanian",
          "identifier": "ro",
          "created_at": "2017-11-22T13:40:59.468Z",
          "updated_at": "2017-11-22T13:41:26.139Z"
        },
        "users_count": 28,
        "vogsphere_id": 1
      }
    ],
    "skills": [
      {
        "id": 2,
        "name": "Company experience",
        "created_at": "2017-11-22T13:41:00.305Z"
      },
      {
        "id": 1,
        "name": "Parallel computing",
        "created_at": "2017-11-22T13:41:00.257Z"
      }
    ],
    "videos": [],
    "tags": [
      {
        "id": 12,
        "name": "Libft",
        "kind": "general"
      }
    ],
    "project_sessions": [
      {
        "id": 1,
        "solo": true,
        "begin_at": null,
        "end_at": null,
        "difficulty": 5000,
        "estimate_time": 2592000,
        "duration_days": null,
        "terminating_after": null,
        "project_id": 1,
        "campus_id": null,
        "cursus_id": null,
        "created_at": "2017-11-22T13:41:26.149Z",
        "updated_at": "2017-11-22T13:42:09.376Z",
        "max_people": null,
        "is_subscriptable": true,
        "scales": [
          {
            "id": 1,
            "correction_number": 3,
            "is_primary": true
          }
        ],
        "uploads": [
          {
            "id": 1,
            "name": "Idaho kangaroos"
          }
        ],
        "team_behaviour": "user"
      }
    ]
  },
  {
    "id": 2,
    "name": "Ordinary Wizarding Levels",
    "slug": "ordinary-wizarding-levels",
    "difficulty": 5000,
    "description": "Ordinary Wizarding Level (often abbreviated O.W.L.) is a subject-specific test taken during Hogwarts School of Witchcraft and Wizardry students' fifth year, administrated by the Wizarding Examinations Authority. The score made by a student on a particular O.W.L. determines whether or not he or she will be allowed to continue taking that subject in subsequent school years.",
    "parent": null,
    "children": [],
    "objectives": [
      "Wizarding"
    ],
    "attachments": [],
    "created_at": "2017-11-22T13:41:26.356Z",
    "updated_at": "2017-11-22T13:41:26.441Z",
    "exam": true,
    "cursus": [
      {
        "id": 1,
        "created_at": "2017-11-22T13:41:00.750Z",
        "name": "Piscine C",
        "slug": "piscine-c"
      }
    ],
    "campus": [
      {
        "id": 1,
        "name": "Cluj",
        "time_zone": "Europe/Bucharest",
        "language": {
          "id": 3,
          "name": "Romanian",
          "identifier": "ro",
          "created_at": "2017-11-22T13:40:59.468Z",
          "updated_at": "2017-11-22T13:41:26.139Z"
        },
        "users_count": 28,
        "vogsphere_id": 1
      }
    ],
    "skills": [
      {
        "id": 1,
        "name": "Parallel computing",
        "created_at": "2017-11-22T13:41:00.257Z"
      },
      {
        "id": 6,
        "name": "Basics",
        "created_at": "2017-11-22T13:41:00.448Z"
      }
    ],
    "videos": [],
    "tags": [
      {
        "id": 13,
        "name": "Ordinary Wizarding Levels",
        "kind": "general"
      }
    ],
    "project_sessions": [
      {
        "id": 2,
        "solo": true,
        "begin_at": null,
        "end_at": null,
        "difficulty": 5000,
        "estimate_time": 2592000,
        "duration_days": null,
        "terminating_after": null,
        "project_id": 2,
        "campus_id": null,
        "cursus_id": null,
        "created_at": "2017-11-22T13:41:26.375Z",
        "updated_at": "2017-11-22T13:41:28.347Z",
        "max_people": null,
        "is_subscriptable": true,
        "scales": [
          {
            "id": 2,
            "correction_number": 3,
            "is_primary": true
          }
        ],
        "uploads": [],
        "team_behaviour": "user"
      }
    ]
  },
  {
    "id": 4,
    "name": "Hogwarts Quidditch Cup",
    "slug": "hogwarts-quidditch-cup",
    "difficulty": 5000,
    "description": "The game starts with the referee releasing all four balls from the central circle. The Bludgers and the Snitch, having been bewitched, fly off of their own accord, the Snitch to hide itself quickly and the Bludgers to attack the nearest players. The Quaffle is thrown into the air by the referee to signal the start of play.",
    "parent": null,
    "children": [
      {
        "name": "Quarter Finals",
        "id": 5,
        "slug": "hogwarts-quidditch-cup-quarter-finals",
        "url": "https://projects.intra.42.fr/hogwarts-quidditch-cup-quarter-finals/mine"
      }
    ],
    "objectives": [
      "Quidditch"
    ],
    "attachments": [],
    "created_at": "2017-11-22T13:41:26.765Z",
    "updated_at": "2017-11-22T13:41:26.975Z",
    "exam": false,
    "cursus": [
      {
        "id": 1,
        "created_at": "2017-11-22T13:41:00.750Z",
        "name": "Piscine C",
        "slug": "piscine-c"
      }
    ],
    "campus": [
      {
        "id": 1,
        "name": "Cluj",
        "time_zone": "Europe/Bucharest",
        "language": {
          "id": 3,
          "name": "Romanian",
          "identifier": "ro",
          "created_at": "2017-11-22T13:40:59.468Z",
          "updated_at": "2017-11-22T13:41:26.139Z"
        },
        "users_count": 28,
        "vogsphere_id": 1
      }
    ],
    "skills": [
      {
        "id": 6,
        "name": "Basics",
        "created_at": "2017-11-22T13:41:00.448Z"
      },
      {
        "id": 1,
        "name": "Parallel computing",
        "created_at": "2017-11-22T13:41:00.257Z"
      }
    ],
    "videos": [],
    "tags": [
      {
        "id": 15,
        "name": "Hogwarts Quidditch Cup",
        "kind": "general"
      }
    ],
    "project_sessions": [
      {
        "id": 4,
        "solo": false,
        "begin_at": null,
        "end_at": null,
        "difficulty": 5000,
        "estimate_time": null,
        "duration_days": null,
        "terminating_after": null,
        "project_id": 4,
        "campus_id": null,
        "cursus_id": null,
        "created_at": "2017-11-22T13:41:26.786Z",
        "updated_at": "2017-11-22T13:41:26.786Z",
        "max_people": null,
        "is_subscriptable": true,
        "scales": [],
        "uploads": [],
        "team_behaviour": "user"
      }
    ]
  }
]