resource "genesyscloud_user" "test_user" {
  email           = "john.carnell@example.com"
  name            = "John Carnell"
  password        = "I@m@Batm@n2"
  state           = "active"
  department      = "Development"
  title           = "Executive Director"
  acd_auto_answer = true
  profile_skills  = ["Java", "Go"]
  certifications  = ["Certified Developer"]
  addresses {
    other_emails {  
      address = "john@gmail.com"
      type    = "HOME"
    }
    phone_numbers {
      number     = "9202655555"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Jonathon Doe"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_user" "test_user2" {
  email           = "tim.smith101@example.com"
  name            = "Tim Smith"
  password        = "I@m@Batm@n2"
  state           = "active"
  department      = "Development"
  title           = "Principle Developer Evangelist"
  acd_auto_answer = true
  profile_skills  = ["Java", "Go"]
  certifications  = ["Certified Developer"]
  addresses {
    other_emails {
      address = "tim@gmail.com"
      type    = "HOME"
    }
    phone_numbers {
      number     = "9202655555"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Jonathon Doe"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}

resource "genesyscloud_user" "robert_smith" {
  email           = "robert.smith@example.com"
  name            = "Robert Smith"
  password        = "I@m@B@tm@nzz2"
  state           = "active"
  department      = "Development"
  title           = "Executive Director"
  acd_auto_answer = true
  profile_skills  = ["Java", "Go"]
  certifications  = ["Certified Developer"]
  addresses {
    other_emails {  
      address = "robert.smithsdada@gmailz.com"
      type    = "HOME"
    }
    phone_numbers {
      number     = "9202651555"
      media_type = "PHONE"
      type       = "MOBILE"
    }
  }
  employer_info {
    official_name = "Rober Smith"
    employee_id   = "12345"
    employee_type = "Full-time"
    date_hire     = "2021-03-18"
  }
}
