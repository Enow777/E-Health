from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "documentation" / "figures"
OUT.mkdir(parents=True, exist_ok=True)

BLACK = "#111111"
GREY = "#F0F0F0"
MID_GREY = "#D8D8D8"
WHITE = "#FFFFFF"


def font(size=22, bold=False):
    names = ["arialbd.ttf", "calibrib.ttf"] if bold else ["arial.ttf", "calibri.ttf"]
    for name in names:
        path = Path("C:/Windows/Fonts") / name
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def canvas(width=1800, height=1200):
    image = Image.new("RGB", (width, height), WHITE)
    return image, ImageDraw.Draw(image)


def draw_text(draw, xy, value, size=22, bold=False, anchor=None, fill=BLACK):
    draw.text(xy, value, fill=fill, font=font(size, bold), anchor=anchor)


def centered_lines(draw, rect, label, size=20, bold=False):
    lines = wrap(label, width=24)
    line_height = size + 5
    cx = (rect[0] + rect[2]) / 2
    cy = (rect[1] + rect[3]) / 2
    y = cy - (len(lines) * line_height) / 2 + 2
    for line in lines:
        draw_text(draw, (cx, y), line, size=size, bold=bold, anchor="ma")
        y += line_height


def actor(draw, x, y, label):
    draw.ellipse((x - 25, y - 105, x + 25, y - 55), outline=BLACK, width=4)
    draw.line((x, y - 55, x, y + 30), fill=BLACK, width=4)
    draw.line((x - 43, y - 20, x + 43, y - 20), fill=BLACK, width=4)
    draw.line((x, y + 30, x - 39, y + 90), fill=BLACK, width=4)
    draw.line((x, y + 30, x + 39, y + 90), fill=BLACK, width=4)
    draw_text(draw, (x, y + 120), label, size=23, bold=True, anchor="ma")


def arrow(draw, start, end, width=3):
    draw.line((start, end), fill=BLACK, width=width)
    x1, y1 = start
    x2, y2 = end
    if abs(x2 - x1) > abs(y2 - y1):
        direction = 1 if x2 > x1 else -1
        points = [
            (x2, y2),
            (x2 - 17 * direction, y2 - 9),
            (x2 - 17 * direction, y2 + 9),
        ]
    else:
        direction = 1 if y2 > y1 else -1
        points = [
            (x2, y2),
            (x2 - 9, y2 - 17 * direction),
            (x2 + 9, y2 - 17 * direction),
        ]
    draw.polygon(points, fill=BLACK)


def dashed_line(draw, start, end, dash=13, gap=8, width=2):
    x1, y1 = start
    x2, y2 = end
    length = ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
    steps = int(length / (dash + gap)) + 1
    for index in range(steps):
        a = index * (dash + gap) / length
        b = min((index * (dash + gap) + dash) / length, 1)
        if a >= 1:
            break
        draw.line(
            (
                x1 + (x2 - x1) * a,
                y1 + (y2 - y1) * a,
                x1 + (x2 - x1) * b,
                y1 + (y2 - y1) * b,
            ),
            fill=BLACK,
            width=width,
        )


def use_case():
    image, draw = canvas(1900, 1510)
    draw_text(draw, (950, 48), "Health Services Mobile Application", 31, True, "ma")
    draw.rounded_rectangle((330, 100, 1570, 1190), 8, outline=BLACK, width=3)

    actor(draw, 145, 520, "Patient")
    actor(draw, 1750, 520, "Doctor")
    actor(draw, 950, 1360, "Administrator")

    patient_cases = [
        (570, 220, "Register / Sign in"),
        (570, 405, "Find doctor"),
        (570, 590, "Book appointment"),
        (570, 775, "View medical records"),
        (570, 960, "Manage medication"),
    ]
    shared_cases = [
        (1050, 330, "Attend teleconsultation"),
        (1050, 520, "Receive notification"),
    ]
    doctor_cases = [
        (1390, 715, "Manage availability"),
        (1390, 880, "Review authorised records"),
        (1390, 1045, "Issue prescription"),
    ]
    admin_cases = [
        (720, 1080, "Verify doctor profile"),
        (1040, 1080, "Manage user access"),
    ]

    for x, y, label in patient_cases + shared_cases + doctor_cases + admin_cases:
        rect = (x - 145, y - 55, x + 145, y + 55)
        draw.ellipse(rect, fill=WHITE, outline=BLACK, width=3)
        centered_lines(draw, rect, label, 19)

    patient_anchor = (195, 520)
    for x, y, _ in patient_cases:
        draw.line((patient_anchor, (x - 145, y)), fill=BLACK, width=2)
    draw.line(
        (patient_anchor, (350, 520), (350, 300), (905, 300), (905, 330)),
        fill=BLACK,
        width=2,
    )
    draw.line((patient_anchor, (905, 520)), fill=BLACK, width=2)

    doctor_anchor = (1700, 520)
    for x, y, _ in doctor_cases:
        draw.line((doctor_anchor, (x + 145, y)), fill=BLACK, width=2)
    for x, y, _ in shared_cases:
        draw.line((doctor_anchor, (x + 145, y)), fill=BLACK, width=2)

    admin_anchor = (950, 1255)
    for x, y, _ in admin_cases:
        draw.line((admin_anchor, (x, y + 55)), fill=BLACK, width=2)

    image.save(OUT / "figure-3-1-use-case.png")


def activity_box(draw, rect, label):
    draw.rounded_rectangle(rect, 18, fill=GREY, outline=BLACK, width=3)
    centered_lines(draw, rect, label, 20)


def decision(draw, center, size=72):
    x, y = center
    draw.polygon(
        [(x, y - size), (x + size, y), (x, y + size), (x - size, y)],
        fill=WHITE,
        outline=BLACK,
    )
    draw.line(
        [(x, y - size), (x + size, y), (x, y + size), (x - size, y), (x, y - size)],
        fill=BLACK,
        width=3,
    )


def activity():
    image, draw = canvas(1600, 1730)
    draw_text(draw, (800, 45), "Patient Appointment-Booking Activity Diagram", 31, True, "ma")

    draw.ellipse((770, 105, 830, 165), fill=BLACK)
    activity_box(draw, (550, 220, 1050, 310), "Launch application")
    activity_box(draw, (550, 380, 1050, 470), "Open doctor directory")
    activity_box(draw, (550, 540, 1050, 630), "Search or select doctor")
    activity_box(draw, (550, 700, 1050, 790), "View doctor profile and availability")
    decision(draw, (800, 925))
    centered_lines(draw, (738, 863, 862, 987), "Suitable slot?", 17, True)
    activity_box(draw, (550, 1080, 1050, 1170), "Choose date, time, and consultation type")
    activity_box(draw, (550, 1240, 1050, 1330), "Confirm appointment")
    activity_box(draw, (550, 1400, 1050, 1490), "Receive appointment reminder")
    draw.ellipse((770, 1570, 830, 1630), fill=WHITE, outline=BLACK, width=3)
    draw.ellipse((780, 1580, 820, 1620), fill=BLACK)

    for start, end in [
        ((800, 165), (800, 220)),
        ((800, 310), (800, 380)),
        ((800, 470), (800, 540)),
        ((800, 630), (800, 700)),
        ((800, 790), (800, 853)),
        ((800, 997), (800, 1080)),
        ((800, 1170), (800, 1240)),
        ((800, 1330), (800, 1400)),
        ((800, 1490), (800, 1570)),
    ]:
        arrow(draw, start, end)

    draw_text(draw, (825, 1030), "[Yes]", 18)
    draw.line((728, 925, 360, 925, 360, 585, 550, 585), fill=BLACK, width=3)
    arrow(draw, (530, 585), (550, 585))
    draw_text(draw, (385, 892), "[No - select another doctor]", 18)

    image.save(OUT / "figure-3-2-activity.png")


def layer(draw, rect, title, items):
    x1, y1, x2, y2 = rect
    draw.rectangle(rect, fill=WHITE, outline=BLACK, width=3)
    draw.rectangle((x1, y1, x2, y1 + 55), fill=MID_GREY, outline=BLACK, width=2)
    draw_text(draw, (x1 + 18, y1 + 16), title, 20, True)
    spacing = (x2 - x1 - 70) / len(items)
    for index, label in enumerate(items):
        left = x1 + 35 + index * spacing
        item = (left, y1 + 88, left + spacing - 24, y2 - 30)
        draw.rectangle(item, fill=GREY, outline=BLACK, width=2)
        centered_lines(draw, item, label, 17)


def architecture():
    image, draw = canvas(1900, 1350)
    draw_text(draw, (950, 45), "Proposed System Architecture", 31, True, "ma")

    layer(
        draw,
        (145, 125, 1755, 340),
        "Presentation Layer",
        ["Flutter mobile application", "Patient screens", "Shared UI components"],
    )
    layer(
        draw,
        (145, 420, 1755, 665),
        "Application Layer",
        [
            "Doctor discovery",
            "Appointment management",
            "Medical records",
            "Prescription management",
            "Notifications",
        ],
    )
    layer(
        draw,
        (145, 745, 1755, 960),
        "Backend Services Layer",
        [
            "Firebase Authentication",
            "Cloud Firestore",
            "Firebase Storage",
            "Firebase Cloud Messaging",
        ],
    )
    layer(
        draw,
        (145, 1040, 1755, 1255),
        "External Services Layer",
        ["Geolocation and maps API", "Secure video consultation API"],
    )

    for start, end in [
        ((950, 340), (950, 420)),
        ((950, 665), (950, 745)),
        ((950, 960), (950, 1040)),
    ]:
        arrow(draw, start, end, 3)

    draw_text(draw, (975, 383), "User actions and responses", 16)
    draw_text(draw, (975, 708), "Authenticated service requests", 16)
    draw_text(draw, (975, 1003), "External API requests", 16)

    image.save(OUT / "figure-3-3-architecture.png")


def entity(draw, x, y, title, fields):
    width = 480
    row_height = 39
    height = 58 + len(fields) * row_height
    draw.rectangle((x, y, x + width, y + height), fill=WHITE, outline=BLACK, width=3)
    draw.rectangle((x, y, x + width, y + 58), fill=MID_GREY, outline=BLACK, width=2)
    draw_text(draw, (x + 18, y + 16), title, 22, True)
    for index, (key_type, field) in enumerate(fields):
        yy = y + 72 + index * row_height
        if key_type:
            draw_text(draw, (x + 18, yy), key_type, 16, True)
        draw_text(draw, (x + 92, yy), field, 17)
    return (x, y, x + width, y + height)


def relation(draw, start, end, left_cardinality, right_cardinality, label, vertical=False):
    draw.line((start, end), fill=BLACK, width=3)
    x1, y1 = start
    x2, y2 = end
    if vertical:
        draw_text(draw, (x1 + 15, y1 + 18), left_cardinality, 17, True)
        draw_text(draw, (x2 + 15, y2 - 34), right_cardinality, 17, True)
        draw_text(draw, (x1 + 42, (y1 + y2) / 2), label, 17, anchor="lm")
    else:
        direction = 1 if x2 > x1 else -1
        draw_text(draw, (x1 + 12 * direction, y1 + 12), left_cardinality, 17, True)
        draw_text(draw, (x2 - 12 * direction, y2 - 34), right_cardinality, 17, True, "ra" if direction > 0 else "la")
        draw_text(draw, ((x1 + x2) / 2, (y1 + y2) / 2 - 24), label, 17, anchor="ma")


def erd():
    image, draw = canvas(1950, 1510)
    draw_text(draw, (975, 45), "Entity Relationship Diagram", 31, True, "ma")

    patient = entity(
        draw,
        110,
        145,
        "PATIENT",
        [
            ("PK", "patientId"),
            ("", "fullName"),
            ("", "email"),
            ("", "phoneNumber"),
        ],
    )
    doctor = entity(
        draw,
        1360,
        145,
        "DOCTOR",
        [
            ("PK", "doctorId"),
            ("", "fullName"),
            ("", "speciality"),
            ("", "clinic"),
        ],
    )
    appointment = entity(
        draw,
        735,
        515,
        "APPOINTMENT",
        [
            ("PK", "appointmentId"),
            ("FK", "patientId"),
            ("FK", "doctorId"),
            ("", "dateTime"),
            ("", "consultationType"),
            ("", "status"),
        ],
    )
    record = entity(
        draw,
        65,
        1110,
        "MEDICAL_RECORD",
        [
            ("PK", "recordId"),
            ("FK", "patientId"),
            ("FK", "appointmentId"),
            ("", "recordType"),
            ("", "fileUrl"),
        ],
    )
    prescription = entity(
        draw,
        735,
        1110,
        "PRESCRIPTION",
        [
            ("PK", "prescriptionId"),
            ("FK", "patientId"),
            ("FK", "doctorId"),
            ("", "medicationName"),
            ("", "dosage"),
            ("", "schedule"),
        ],
    )
    notification = entity(
        draw,
        1405,
        1110,
        "NOTIFICATION",
        [
            ("PK", "notificationId"),
            ("FK", "patientId"),
            ("", "category"),
            ("", "message"),
            ("", "isRead"),
        ],
    )

    relation(draw, (590, 270), (735, 610), "1", "0..*", "books")
    relation(draw, (1360, 270), (1215, 610), "1", "0..*", "receives")
    relation(draw, (830, 807), (480, 1110), "1", "0..*", "produces")
    relation(draw, (975, 807), (975, 1110), "1", "0..*", "creates", True)
    relation(draw, (1120, 807), (1480, 1110), "1", "0..*", "triggers")

    image.save(OUT / "figure-3-4-erd.png")


if __name__ == "__main__":
    use_case()
    activity()
    architecture()
    erd()
    print(f"Generated UML-style Chapter Three figures in {OUT}")
