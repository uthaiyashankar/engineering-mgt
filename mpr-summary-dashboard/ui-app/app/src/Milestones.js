import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import MilestoneMenuBar from './MilestoneMenuBar'
import axios from 'axios';
import TextField from 'material-ui/TextField';
import MilestoneTable from './MilestoneTable';
import { FormControl } from 'material-ui/Form';

var config = require('./config.json');

const hostUrl = config.url + config.service_path;

const styles = theme => ({
    root: {
        width: '100%',
        marginTop: theme.spacing.unit * 3,
        overflowX: 'auto',
    },
    table: {
        minWidth: 700,
    },
    formControl: {
        margin: theme.spacing.unit,
        minWidth: 210,
    },
    textField: {
        margin: theme.spacing.unit,
        minWidth: 500,
    },
});

class Milestones extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            error: null,
            data:null,
            name:'',
        };

        this.onSubmit = this.onSubmit.bind(this);
        this.loadMilestones = this.loadMilestones.bind(this);
    }

    onSubmit(info) {
        const name = this.state.name;
        if(name==='') {
            alert("Please give a valid name for the milestone.");
            return;
        }


        var url = hostUrl + '/setmilestone?';
        url += 'name='+name+'&';
        url += 'product='+info.product+'&';
        url += 'version='+info.version+'&';
        url += 'start='+info.dateFrom.toISOString();
        url += '&end='+info.dateTo.toISOString();
        url = encodeURI(url);
        axios.get(url)
            .then(response => {
                if(response.data==='success') {
                    this.loadMilestones();
                } else {
                    alert(response.data);
                }
            })
            .catch(error => {
               alert(error);
            });
    }


    handleChange = name => event => {
        this.setState({
            [name]: event.target.value,
        });
    };

    loadMilestones() {
        var url = hostUrl + '/milestones';
        console.log(url);
        url = encodeURI(url);
        axios.get(url)
            .then(response => {
                if(response.data) {
                    this.setState({data:response.data.data});
                }
            })
            .catch(error => {
                alert(error);
            });
    }

    componentDidMount() {
        this.loadMilestones();
    }



    render() {
        const { classes } = this.props;
        return(

            <div>
                {/*<form className={classes.root} autoComplete="off">*/}
                    <FormControl className={classes.formControl}>
                        <h3>Add Milestone </h3>
                        <b>Name: </b>
                        <div>
                            <TextField
                                id="name"
                                // label="Name"
                                value={this.state.name}
                                className={classes.textField}
                                onChange={this.handleChange('name')}
                                margin="normal"
                            />
                        </div>
                        <MilestoneMenuBar
                            buttonText={'Add'}
                            onSubmit={this.onSubmit}
                        />
                    </FormControl>
                {/*</form>*/}
                <hr/>
                {this.state.data!==null &&
                    <MilestoneTable
                        data={this.state.data}
                        loadMilestones={this.loadMilestones}
                    />
                }
            </div>
        );
    }
}

Milestones.propTypes = {
    classes: PropTypes.object.isRequired,
};

export default withStyles(styles)(Milestones);