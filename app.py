from flask import Flask, Response, request
from flask_sqlalchemy import SQLAlchemy
import os, sqlalchemy
#
#
#
app = Flask(__name__)
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'database.sqlite')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Decision(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    decision = db.Column(db.String(100), nullable=False)
    # created_at = db.Column(db.DateTime(timezone=True), server_default=sqlalchemy.sql.func.now())
#
#
#
#
#
#
#
@app.route("/")
def index():
    return "Rein desu\n"
#
#
#
@app.route("/api/decisions", methods=('GET', 'POST', 'DELETE'))
def decisions():
    if request.method == 'GET':
        decisions = Decision.query.all()
        result = []
        for decision in decisions:
            result.append({
                "id": decision.id,
                "decision": decision.decision,
                # "created_at": decision.created_at,
            })
        return result
    if request.method == 'DELETE':
        return 'delete'
#
#
#
#
#
if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=int(8080))
